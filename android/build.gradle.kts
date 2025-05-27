// android/build.gradle.kts
buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("com.google.gms:google-services:4.3.15")
        // You might need other classpath dependencies here,
        // for example, the Android Gradle Plugin:
        // classpath("com.android.tools.build:gradle:YOUR_AGP_VERSION")
        // classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:YOUR_KOTLIN_VERSION")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
        // You can add other repositories like jcenter() if needed,
        // or specific Maven URLs for other dependencies.
    }
}

// Configuration for changing the build directory location
val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.set(newBuildDir) // Use .set() for Provider

subprojects {
    // Ensure this path is relative to the new root build directory
    val newSubprojectBuildDir: Directory = rootProject.layout.buildDirectory.get().dir(project.name)
    project.layout.buildDirectory.set(newSubprojectBuildDir) // Use .set() for Provider
}

// This dependency ensures that the :app project is configured before other subprojects.
// This can be useful if other subprojects consume outputs or configurations from :app.
// However, if not strictly necessary, removing it or making it more specific can
// improve build configuration times and reduce coupling.
subprojects {
    if (project.name != "app") { // Avoid :app depending on itself for evaluation
        project.evaluationDependsOn(":app")
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}