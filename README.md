# Welcome to Hi Town, or Chào Town
### (formerly Who is Who, or Ai là ai)

This is a KMM version of AiLàiAi to support android and ios.

# Development with Android Studio

Follow the instructions at https://kotlinlang.org/docs/multiplatform-mobile-getting-started.html and then:

## Step 1: edit `local.properties` file

For gradle to find your installation of Java, and to suppress some warnings, add these lines:

```bash
# Java (uncomment one line)
# org.gradle.java.home=/usr/lib/jvm/jre-openjdk/
# org.gradle.java.home=/Library/Java/JavaVirtualMachines/temurin-17.jdk/Contents/Home

# Suppress unbuildable target and gradle plugin version warnings
kotlin.native.ignoreDisabledTargets=true
kotlin.mpp.androidGradlePluginCompatibility.nowarn=true
```

## Step 2: connect a device

Connect a physical device or create a virtual device with Android Studio's Device Manager.

## Step 3: run on device

Press the `Run 'DefaultPreview''` button in the toolbar or press Shift + F10 to run the app.
