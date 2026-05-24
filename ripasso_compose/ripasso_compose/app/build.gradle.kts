plugins {
    alias(libs.plugins.android.application)
    alias(libs.plugins.kotlin.android)

    id("org.jetbrains.kotlin.plugin.compose") version "2.0.21"

    alias(libs.plugins.hilt)
    kotlin("kapt")
}
android {
    namespace = "com.example.ripasso_compose"
    compileSdk = 34

    defaultConfig {
        applicationId = "com.example.ripasso_compose"
        minSdk = 24
        targetSdk = 34
        versionCode = 1
        versionName = "1.0"
    }

    buildFeatures {
        compose = true
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = "11"
    }
}

dependencies {

    implementation(libs.androidx.core.ktx)
    implementation(libs.androidx.lifecycle.runtime.ktx)
    implementation(libs.androidx.activity.compose)

    implementation(platform(libs.androidx.compose.bom))
    implementation(libs.androidx.ui)
    implementation(libs.androidx.ui.graphics)
    implementation(libs.androidx.ui.tooling.preview)
    implementation(libs.androidx.material3)

    debugImplementation(libs.androidx.ui.tooling)

    // Hilt
    implementation(libs.hilt.android)
    kapt(libs.hilt.compiler)

    implementation("io.coil-kt.coil3:coil-compose:3.0.0") // O versione successiva
    implementation("io.coil-kt.coil3:coil-network-okhttp:3.0.0")

    implementation(libs.androidx.hilt.navigation.compose)

    // Retrofit
    implementation(libs.retrofit)
    implementation(libs.converter.gson)
    implementation(libs.okhttp)
    implementation(libs.logging.interceptor)

    // Serialization
    implementation(libs.kotlinx.serialization.json)
    implementation(libs.retrofit2.kotlinx)

    /* Versioni estesi
    // Hilt
        implementation("com.google.dagger:hilt-android:<version>")
        kapt("com.google.dagger:hilt-compiler:<version>")

        implementation("io.coil-kt.coil3:coil-compose:3.0.0")
        implementation("io.coil-kt.coil3:coil-network-okhttp:3.0.0")

        implementation("androidx.hilt:hilt-navigation-compose:<version>")

    // Retrofit
        implementation("com.squareup.retrofit2:retrofit:<version>")
        implementation("com.squareup.retrofit2:converter-gson:<version>")
        implementation("com.squareup.okhttp3:okhttp:<version>")
        implementation("com.squareup.okhttp3:logging-interceptor:<version>")

    // Serialization
        implementation("org.jetbrains.kotlinx:kotlinx-serialization-json:<version>")
        implementation("com.jakewharton.retrofit:retrofit2-kotlinx-serialization-converter:<version>")
        */

}