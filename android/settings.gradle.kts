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
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    // Flutter 3.44 template AGP (9.0.1) + Gradle 9.1.0 (the only Gradle
    // distribution that reliably downloads on CI). All modules (app + plugins,
    // now upgraded to AGP-9-compatible versions) use AGP 9.0's built-in Kotlin,
    // so the kotlin-android plugin is never applied. Kotlin version kept at the
    // template default 2.3.20 (unused now, but matches the Flutter template).
    id("com.android.application") version "9.0.1" apply false
    id("org.jetbrains.kotlin.android") version "2.3.20" apply false
}

include(":app")
