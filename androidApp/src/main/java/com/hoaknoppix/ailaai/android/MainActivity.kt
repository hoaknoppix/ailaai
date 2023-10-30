package com.hoaknoppix.ailaai.android

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.tooling.preview.Preview
import com.hoaknoppix.ailaai.Greeting
import com.hoaknoppix.ailaai.Platform
import com.hoaknoppix.ailaai.getPlatform

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            MyApplicationTheme {
                Surface(
                    modifier = Modifier.fillMaxSize(),
                    color = MaterialTheme.colors.background
                ) {
                    GreetingView(Greeting().greet())
                }
            }
        }
    }
}

@Composable
fun GreetingView(text: String) {
    Text(text = text, color = MaterialTheme.colors.secondary)
}

@Preview
@Composable
fun DefaultPreview() {
    val platform: Platform = getPlatform()
    MyApplicationTheme {
        GreetingView("Hello, you are on $platform. Welcome to Hi Town, or Chào Town (formerly Who is Who, or Ai là ai)")
    }
}
