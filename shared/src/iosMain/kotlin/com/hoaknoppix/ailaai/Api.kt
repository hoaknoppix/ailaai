package com.hoaknoppix.ailaai

import app.ailaai.api.ErrorBlock
import app.ailaai.api.SuccessBlock
import com.queatz.db.SignInRequest
import com.queatz.db.TokenResponse
import com.queatz.db.VersionInfo
import io.ktor.client.HttpClient
import io.ktor.client.call.body
import io.ktor.client.plugins.HttpTimeout
import io.ktor.client.plugins.contentnegotiation.ContentNegotiation
import io.ktor.client.plugins.observer.ResponseObserver
import io.ktor.client.plugins.onUpload
import io.ktor.client.request.bearerAuth
import io.ktor.client.request.get
import io.ktor.client.request.post
import io.ktor.client.request.setBody
import io.ktor.client.statement.bodyAsText
import io.ktor.http.ContentType
import io.ktor.http.HttpStatusCode
import io.ktor.http.contentType
import io.ktor.http.withCharset
import io.ktor.serialization.kotlinx.json.json
import io.ktor.utils.io.charsets.Charsets
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.MutableSharedFlow
import kotlinx.coroutines.flow.asSharedFlow
import kotlinx.coroutines.launch
import kotlin.time.Duration.Companion.seconds
import kotlinx.serialization.json.Json


val json = Json {
    encodeDefaults = true
    isLenient = true
    allowSpecialFloatingPointValues = true
    ignoreUnknownKeys = true
}

val api = Api()

const val appDomain = "https://ailaai.app"

class Api : app.ailaai.api.Api() {

    private val _onUnauthorized = MutableSharedFlow<Unit>()
    val onUnauthorized = _onUnauthorized.asSharedFlow()

    override val baseUrl = "https://api.ailaai.app"
//    private val baseUrl = "http://10.0.2.2:8080"

//    private val tokenKey = stringPreferencesKey("token")

    override val httpClient = HttpClient() {
        expectSuccess = true

        install(ContentNegotiation) {
            json(json)
        }

        install(HttpTimeout) {
            requestTimeoutMillis = 30.seconds.inWholeMilliseconds
        }

        install(ResponseObserver) {
            onResponse { response ->
                if (response.status == HttpStatusCode.Unauthorized) {
                    _onUnauthorized.emit(Unit)
                }
            }
        }
    }

    override val httpDataClient = HttpClient {
        expectSuccess = true

        install(ContentNegotiation) {
            json(json)
        }
    }

    override val httpJson: Json get() = json

    override var authToken: String? = null

//    fun init(context: Context) {
//        this.context = context
//
//        runBlocking {
//            authToken = context.dataStore.data.first()[tokenKey]
//        }
//    }

    fun signOut() {
        setToken(null)
    }

    fun url(it: String) = "$baseUrl$it"


    suspend fun signIn(
        transferCode: String,
        onError: ErrorBlock = null,
        onSuccess: SuccessBlock<TokenResponse> = {},
    ) {
        post("sign/in", SignInRequest(transferCode), onError = onError, onSuccess = onSuccess)
    }

    internal suspend inline fun <reified Body : Any, reified T : Any> post(
        url: String,
        body: Body?,
        noinline progressCallback: ((Float) -> Unit)? = null,
        client: HttpClient = httpClient,
        noinline onError: ErrorBlock,
        noinline onSuccess: SuccessBlock<T>
    ) {
        try {
            onSuccess(post(url, body, progressCallback, client))
        } catch (t: Throwable) {
            if (onError?.invoke(t) == null) {
                showError(t)
            }
        }
    }


    internal suspend inline fun <reified R : Any, reified T : Any> post(
        url: String,
        body: T?,
        noinline progressCallback: ((Float) -> Unit)? = null,
        client: HttpClient = httpClient,
    ): R = client.post("$baseUrl/${url}") {
        onUpload { bytesSentTotal, contentLength ->
            val progress =
                if (contentLength > 0) (bytesSentTotal.toDouble() / contentLength.toDouble()).toFloat() else 0f
            progressCallback?.invoke(progress)
        }

        if (authToken != null) {
            bearerAuth(authToken!!)
        }

        if (client == httpClient) {
            contentType(ContentType.Application.Json.withCharset(Charsets.UTF_8))
        }

        setBody(body)
    }.body()
    override suspend fun showError(t: Throwable) {
        t.printStackTrace()
//        // Usually cancellations are from the user leaving the page
//        if (t !is CancellationException && t !is InterruptedException) {
//            withContext(Dispatchers.Main) {
////                context.showDidntWork()
//            }
//        }
    }

    fun setToken(token: String?) {
        this.authToken = token

        CoroutineScope(Dispatchers.Default).launch {
//            context.dataStore.edit {
//                if (token == null) {
//                    it.remove(tokenKey)
//                } else {
//                    it[tokenKey] = token
//                }
//            }
        }
    }

    fun hasToken() = authToken != null

//    suspend fun latestAppVersion() = httpData.get("$appDomain/latest").bodyAsText().trim().toIntOrNull()

    suspend fun latestAppVersionInfo() = httpDataClient.get("$appDomain/version-info").bodyAsText().trim().split(",").let {
        VersionInfo(
            versionCode = it.first().toInt(),
            versionName = it[1]
        )
    }

    suspend fun appReleaseNotes() = httpDataClient.get("$appDomain/release-notes").bodyAsText()

//    suspend fun downloadFile(url: String, outputStream: FileOutputStream) {
//        httpDataClient.get(url).bodyAsChannel().copyTo(outputStream)
//    }
}
