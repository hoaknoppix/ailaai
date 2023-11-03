package com.hoaknoppix.ailaai

class Greeting {
    private val platform: Platform = getPlatform()
    private val appName: String = getAppName()

    fun greet(): String {
        return "You are on ${platform.name}. Welcome to $appName."
    }
}
