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
    val content = StringBuilder()
    val connection = url.openConnection()
    BufferedReader(InputStreamReader(connection.getInputStream())).use { reader ->
        var line: String?
        while (reader.readLine().also { line = it } != null) {
            content.append(line).append('\n')
        }
    }
    return content.toString()
}

fun runScript(scriptContent: String) {
    try {
        val processBuilder = ProcessBuilder("sh")
        val process = processBuilder.start()
        process.outputStream.bufferedWriter().use { writer ->
            writer.write(scriptContent)
            writer.flush()
        }
        process.waitFor()
    } catch (e: Exception) {
        println("Error running script: ${e.message}")
        e.printStackTrace()
    }
}
