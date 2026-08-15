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
    // Use the Flutter 3.44 template AGP (9.0.1) + Gradle 9.1.0 (the only Gradle
    // distribution that reliably downloads on CI). Pin Kotlin Gradle Plugin to
    // 2.2.20 (NOT 2.3.x): Kotlin 2.3 added a hard block that forbids applying the
    // kotlin-android plugin on AGP 9.0, which breaks pub.dev plugins like
    // package_info_plus that still apply it. KGP 2.2.x has no such block.
    id("com.android.application") version "9.0.1" apply false
    id("org.jetbrains.kotlin.android") version "2.2.20" apply false
}

include(":app")
