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
    // 2.1.0: the AGP-9 "built-in Kotlin" check that forbids applying the
    // kotlin-android plugin (AgpWithBuiltInKotlinAppliedCheck) was introduced in
    // Kotlin 2.2.0, so 2.1.0 does NOT have it and lets pub.dev plugins that still
    // apply kotlin-android build on AGP 9.0. 2.1.0 >= Flutter's minimum KGP 2.0.0.
    id("com.android.application") version "9.0.1" apply false
    id("org.jetbrains.kotlin.android") version "2.1.0" apply false
}

include(":app")
