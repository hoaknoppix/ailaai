buildscript {
    val agp_version by extra("8.1.2")
    dependencies {
        classpath("com.android.tools.build:gradle:8.0.2")
    }
}
plugins {
    //trick: for the same plugin versions in all sub-modules
    id("com.android.application").version("8.1.2").apply(false)
    id("com.android.library").version("8.1.2").apply(false)
    kotlin("android").version("1.9.20").apply(false)
    kotlin("multiplatform").version("1.9.20").apply(false)
}

tasks.register("clean", Delete::class) {
    delete(rootProject.buildDir)
}
