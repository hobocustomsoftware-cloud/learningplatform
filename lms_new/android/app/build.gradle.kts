plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.lms"
    compileSdk = 34

    defaultConfig {
        applicationId = "com.example.lms"
        minSdk = 24
        targetSdk = 34
        versionCode = 1
        versionName = "1.0"
        multiDexEnabled = true
    }

    // ❗ error ကို ဖြေရှင်းရန် — debug မှာ shrink မလုပ်ပါ
    buildTypes {
        getByName("debug") {
            // debug build များတွင် resource shrink ပိတ်ထားပါ
            isMinifyEnabled = false
            isShrinkResources = false
        }
        getByName("release") {
            // release မှာတော့ shrink လုပ်ချင်ရင် 둘다 on
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    packaging {
        resources {
            excludes += setOf(
                "META-INF/DEPENDENCIES",
                "META-INF/LICENSE",
                "META-INF/LICENSE.txt",
                "META-INF/license.txt",
                "META-INF/NOTICE",
                "META-INF/NOTICE.txt",
                "META-INF/notice.txt",
                "META-INF/ASL2.0"
            )
        }
    }
}

dependencies {
    // Kotlin stdlib (KGP 2.1.0 သုံးလို့ ကွာဟချက်မရှိ)
    implementation("org.jetbrains.kotlin:kotlin-stdlib:2.1.0")

    // Desugaring (သုံးမိရင်)
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}
