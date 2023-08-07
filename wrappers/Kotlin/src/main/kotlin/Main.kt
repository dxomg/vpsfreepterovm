import java.io.File
import java.net.URL
import java.nio.file.Files
import java.nio.file.Paths
import java.nio.file.StandardCopyOption

fun main() {
    val installedFile = File(".installed")

    if (installedFile.exists()) {
        val harborScript = File("harbor.sh")
        if (harborScript.exists()) {
            executeHarborScript(harborScript)
        } else {
            println("harbor.sh not found.")
        }
    } else {
        val scanner = java.util.Scanner(System.`in`)

        println("Do you want to use the existing URL or provide a custom one?")
        println("1. Existing URL")
        println("2. Custom URL")
        print("Enter your choice (1 or 2): ")
        val choice = scanner.nextInt()

        val url: URL = when (choice) {
            1 -> URL("https://raw.githubusercontent.com/dxomg/Harbor/main/harbor.sh")
            2 -> {
                print("Enter the custom URL: ")
                URL(scanner.next())
            }
            else -> {
                println("Invalid choice. Using the existing URL.")
                URL("https://raw.githubusercontent.com/dxomg/Harbor/main/harbor.sh")
            }
        }

        val destination = File("harbor.sh")

        if (destination.exists()) {
            executeHarborScript(destination)
            installedFile.createNewFile()
        } else {
            try {
                downloadFile(url, destination)

                // Set executable permission on downloaded file
                val chmod = ProcessBuilder("chmod", "+x", destination.name)
                chmod.inheritIO()
                chmod.start().waitFor()

                // Run the downloaded file
                executeHarborScript(destination)
                installedFile.createNewFile()
            } catch (e: Exception) {
                println("Error downloading or running script: ${e.message}")
                e.printStackTrace()
            }
        }
    }
}

fun executeHarborScript(destination: File) {
    try {
        // Run the script
        val harbor = ProcessBuilder("sh", destination.name)
        harbor.inheritIO()
        harbor.start().waitFor()
    } catch (e: Exception) {
        println("Error running script: ${e.message}")
        e.printStackTrace()
    }
}

fun downloadFile(url: URL, destination: File) {
    Files.copy(url.openStream(), Paths.get(destination.toURI()), StandardCopyOption.REPLACE_EXISTING)
}
