plugins {
    id("com.android.application")
    // AGP 9.0+ provides built-in Kotlin, so the kotlin-android plugin must NOT be
    // applied here (app and all plugins now use AGP 9.0's built-in Kotlin).
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.localplayer.local_video_player"
    // permission_handler_android 14.0.0 requires compileSdk >= 37 (Android 15).
    // The CI Flutter toolchain's flutter.compileSdkVersion resolves lower, so we
    // pin explicit values to satisfy the checkDebugAarMetadata SDK requirement.
    compileSdk = 37
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.localplayer.local_video_player"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = 37
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
