pluginManagement {
    val flutterSdkPath =
        run {
            val properties = java.util.Properties()
            file("local.properties").inputStream().use { properties.load(it) }
            val flutterSdkPath = properties.getProperty("flutter.sdk")
            require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
            flutterSdkPath
        }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        // Mirror-first strategy for better stability in CN networks.
        maven("https://maven.aliyun.com/repository/gradle-plugin")
        maven("https://maven.aliyun.com/repository/google")
        maven("https://maven.aliyun.com/repository/public")

        google()
        mavenCentral()
        // Keep plugin portal as the last fallback.
        gradlePluginPortal()
    }

    resolutionStrategy {
        eachPlugin {
            val version = requested.version ?: return@eachPlugin
            when (requested.id.id) {
                "com.android.application",
                "com.android.library",
                "com.android.dynamic-feature",
                "com.android.test" -> useModule("com.android.tools.build:gradle:$version")

                "org.jetbrains.kotlin.android",
                "org.jetbrains.kotlin.jvm",
                "org.jetbrains.kotlin.kapt",
                "org.jetbrains.kotlin.plugin.parcelize",
                "org.jetbrains.kotlin.plugin.serialization" ->
                    useModule("org.jetbrains.kotlin:kotlin-gradle-plugin:$version")
            }
        }
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.11.1" apply false
    id("org.jetbrains.kotlin.android") version "2.2.20" apply false
}

include(":app")
