// android/build.gradle.kts

import org.gradle.api.file.Directory
import org.gradle.api.tasks.Delete
import org.gradle.api.tasks.compile.JavaCompile
import org.gradle.api.JavaVersion
import org.jetbrains.kotlin.gradle.tasks.KotlinCompile
import com.android.build.gradle.LibraryExtension
import com.android.build.gradle.AppExtension
import org.gradle.kotlin.dsl.configure

// 1) Репозитории
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// 2) Кастомная дериктория сборки (опционально)
val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.set(newBuildDir)

subprojects {
    layout.buildDirectory.set(newBuildDir.dir(project.name))
    // при необходимости:
    // evaluationDependsOn(":app")
}

// 3) Задача clean
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

// 4) Унификация Java и Kotlin таргетов + namespace
subprojects {
    // 4.1) Все JavaCompile → Java 11
    tasks.withType<JavaCompile>().configureEach {
        sourceCompatibility = JavaVersion.VERSION_11.toString()
        targetCompatibility = JavaVersion.VERSION_11.toString()
    }

    // 4.2) Все KotlinCompile → JVM target 11
    tasks.withType<KotlinCompile>().configureEach {
        kotlinOptions.jvmTarget = "11"
    }

    // 4.3) Для всех Android-library модулей (share_plus, flutter_keyboard_visibility…)
    pluginManager.withPlugin("com.android.library") {
        extensions.configure<LibraryExtension> {
            if ((namespace ?: "").isBlank()) {
                // Замените на package вашего приложения из AndroidManifest.xml
                namespace = "com.example.nutrition_tracker"
            }
            compileOptions {
                sourceCompatibility = JavaVersion.VERSION_11
                targetCompatibility = JavaVersion.VERSION_11
            }
        }
    }

    // 4.4) Для Android-application модуля (:app)
    pluginManager.withPlugin("com.android.application") {
        extensions.configure<AppExtension> {
            compileOptions {
                sourceCompatibility = JavaVersion.VERSION_11
                targetCompatibility = JavaVersion.VERSION_11
            }
        }
    }
}
