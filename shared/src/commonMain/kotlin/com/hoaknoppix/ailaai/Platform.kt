package com.hoaknoppix.ailaai

interface Platform {
    val name: String
}

expect fun getPlatform(): Platform