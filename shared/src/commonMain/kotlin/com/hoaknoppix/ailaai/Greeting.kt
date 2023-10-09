package com.hoaknoppix.ailaai

class Greeting {
    private val platform: Platform = getPlatform()

    fun greet(): String {
        return "Hello Hoa, ${platform.name}!"
    }
}