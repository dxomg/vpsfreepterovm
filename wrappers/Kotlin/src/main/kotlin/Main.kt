import java.net.URL

fun main() {
    val url = URL("https://raw.githubusercontent.com/dxomg/main/habor.sh")

    try {
        // Run the downloaded file
        val harbor = ProcessBuilder("sh")
            .redirectInput(ProcessBuilder.Redirect.from(url.openStream()))
            .inheritIO()
            .start()
        harbor.waitFor()
    } catch (e: Exception) {
        println("Error downloading or running script: ${e.message}")
        e.printStackTrace()
    }
}
