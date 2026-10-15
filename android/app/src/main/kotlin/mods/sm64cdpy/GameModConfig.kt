package mods.sm64cdpy

/** Lossless editing of the game's enable-mod directives; no other setting is owned here. */
internal object GameModConfig {
    fun identity(line: String): String? {
        val tokens = line.trim().split(Regex("\\s+")).take(20)
        if (tokens.size < 2 || tokens[0] != "enable-mod:") return null
        return tokens.drop(1).joinToString(" ")
    }

    fun enabled(text: String): Set<String> = text.lineSequence().mapNotNull(::identity).toSet()

    fun validName(name: String): Boolean = name.isNotBlank() &&
        name.toByteArray(Charsets.UTF_8).size < 256 &&
        !name.startsWith('.') && name.all { it in ' '..'~' && it !in "/\\<>:\"|?*" } &&
        name.trim().split(Regex("\\s+")).joinToString(" ") == name &&
        name.split(' ').size <= 19

    fun edit(text: String, name: String, enable: Boolean): String {
        require(validName(name))
        val newline = if (text.contains("\r\n")) "\r\n" else "\n"
        // Keep every unrelated line byte-for-byte, including its line ending.
        val lines = Regex("[^\\n]*\\n|[^\\n]+$").findAll(text).map { it.value }.toList()
        val retained = lines.filter { identity(it) != name }.joinToString("")
        if (!enable) return retained
        return retained + (if (retained.isNotEmpty() && !retained.endsWith('\n')) newline else "") +
            "enable-mod: $name$newline"
    }
}
