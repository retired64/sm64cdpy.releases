package mods.sm64cdpy

/** configfile.c::dynos_pack_read/write, including the legacy terminal boolean. */
internal object GameDynosConfig {
    private fun tokens(line: String): List<String>? {
        val tokens = line.trim().split(Regex("\\s+")).take(20)
        return tokens.takeIf { it.size >= 2 && it[0] == "dynos-pack:" }
    }
    fun identity(line: String): String? {
        val tokens = tokens(line) ?: return null
        val words = tokens.drop(1).let {
            if (it.last() == "true" || it.last() == "false") it.dropLast(1) else it
        }
        return words.joinToString(" ").takeIf { it.isNotEmpty() }
    }
    fun enabled(text: String): Set<String> = text.lineSequence().mapNotNull { line ->
        if (tokens(line)?.last() == "false") null else identity(line)
    }.toSet()
    fun validName(name: String): Boolean = GameModConfig.validName(name) &&
        name.substringAfterLast(' ') !in setOf("true", "false")

    fun edit(text: String, name: String, enable: Boolean): String {
        require(validName(name))
        val newline = if (text.contains("\r\n")) "\r\n" else "\n"
        val retained = Regex("[^\\n]*\\n|[^\\n]+$").findAll(text)
            .map { it.value }.filter { identity(it) != name }.joinToString("")
        if (!enable) return retained
        return retained + (if (retained.isNotEmpty() && !retained.endsWith('\n')) newline else "") +
            "dynos-pack: $name$newline"
    }
}
