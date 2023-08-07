import java.io.BufferedReader
import java.io.InputStreamReader
import java.net.URL

fun main() {
    val url = URL("https://raw.githubusercontent.com/RealTriassic/Harbor/main/harbor.sh")

    try {
        val scriptContent = downloadScript(url)
        runScript(scriptContent)
    } catch (e: Exception) {
        println("Error downloading or running script: ${e.message}")
        e.printStackTrace()
    }
}

fun downloadScript(url: URL): String {
    val connection = url.openConnection()
    val reader = BufferedReader(InputStreamReader(connection.getInputStream()))

    val scriptContent = StringBuilder()
    var inputLine: String?

    while (reader.readLine().also { inputLine = it } != null) {
        scriptContent.appendln(inputLine)
    }

    reader.close()
    return scriptContent.toString()
}

fun runScript(scriptContent: String) {
    val processBuilder = ProcessBuilder("sh")
    val process = processBuilder.start()

    val outputStream = process.outputStream
    outputStream.bufferedWriter().use { it.write(scriptContent) }

    process.waitFor()
}
