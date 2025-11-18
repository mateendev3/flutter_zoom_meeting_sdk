allprojects {
    repositories {
        google()
        mavenCentral()
        // Local Zoom MobileRTC artifacts (copied into example/android)
        maven {
            url = uri(rootProject.file("mobilertc-repo"))
        }
        flatDir {
            dirs(rootProject.file("mobilertc"))
        }
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
