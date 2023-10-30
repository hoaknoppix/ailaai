package com.hoaknoppix.ailaai

class Greeting {
    private val platform: Platform = getPlatform()

    fun greet(): String {
        return "You are on ${platform.name}. Welcome to Hi Town, or Chào Town (formerly Who is Who, or Ai là ai)"
    }
}