plugins {
    kotlin("multiplatform")
    kotlin("native.cocoapods")
    id("com.android.library")
}

@OptIn(org.jetbrains.kotlin.gradle.ExperimentalKotlinGradlePluginApi::class)
kotlin {
    targetHierarchy.default()
    android {
        compilations.all {
            kotlinOptions {
                jvmTarget = "1.8"
            }
        }
    }
    iosX64()
    iosArm64()
    iosSimulatorArm64()

    cocoapods {
        summary = "Some description for the Shared Module"
        homepage = "Link to the Shared Module homepage"
        version = "1.0"
        ios.deploymentTarget = "14.1"
        podfile = project.file("../iosApp/Podfile")
        framework {
            baseName = "shared"
        }
    }
    
    sourceSets {
        val iosArm64Main by getting {
            dependencies {
                val ktorVersion = "2.3.6"
//                implementation("app.ailaai.shared:models")
//                implementation("app.ailaai.shared:push")
//                implementation("app.ailaai.shared:api")
//                implementation("io.ktor:ktor-client-core-native:$ktorVersion")
//                implementation("io.ktor:ktor-client-ios:$ktorVersion")

                implementation("io.ktor:ktor-client-darwin:$ktorVersion")
            }
        }
        val commonMain by getting {
            dependencies {
                val ktorVersion = "2.3.6"
                //put your multiplatform dependencies here
                implementation("app.ailaai.shared:models")
                implementation("app.ailaai.shared:push")
                implementation("app.ailaai.shared:api")
                implementation("org.jetbrains.kotlinx:kotlinx-serialization-core:1.6.0")
                implementation("org.jetbrains.kotlinx:kotlinx-serialization-json:1.6.0")
                implementation("org.jetbrains.kotlinx:kotlinx-coroutines-core:1.7.3")
                implementation("io.ktor:ktor-client-core:$ktorVersion")
                implementation("io.ktor:ktor-client-content-negotiation:$ktorVersion")
                implementation("io.ktor:ktor-serialization-kotlinx-json:$ktorVersion")
            }
        }
        val commonTest by getting {
            dependencies {
                implementation(kotlin("test"))
            }
        }
    }
}

android {
    namespace = "com.hoaknoppix.ailaai"
    compileSdk = 33
    defaultConfig {
        minSdk = 24
    }
}