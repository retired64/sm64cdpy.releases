package mods.sm64cdpy

/** Display metadata only. Does not decide whether the game loads/enables a mod. */
internal object LuaModMetadata {
    data class Info(
        val name: String? = null,
        val version: String? = null,
        val category: String? = null,
        val author: String? = null,
        val description: String? = null
    )

    fun parse(text: String, fallbackName: String): Info {
        var name: String? = null
        var category: String? = null
        var author: String? = null
        var description: String? = null
        val normalized = text.removePrefix("\uFEFF")
        for (raw in normalized.lineSequence()) {
            val line = raw.trimEnd('\r')
            if (!line.startsWith("--")) break
            val separator = line.indexOf(':')
            if (separator < 2) continue
            val key = line.substring(2, separator).trim().lowercase()
            val value = clean(line.substring(separator + 1)).takeIf(String::isNotBlank)
            when (key) {
                "name" -> if (name == null) name = value?.take(64)
                "category" -> if (category == null) category = value?.take(64)
                "author" -> if (author == null) author = value?.take(128)
                "description" -> if (description == null) description = value?.take(800)
            }
        }
        val version = extractVersion(name, description, fallbackName)
        return Info(name, version, category, author, description)
    }

    internal fun clean(value: String): String = value
        .replace("\\n", " ")
        .replace(Regex("\\\\+#[0-9A-Fa-f]{6}\\\\+"), "")
        .replace(Regex("\\\\+"), "")
        .replace(Regex("[ \\t]{2,}"), " ")
        .trim()

    fun extractVersion(vararg texts: String?): String? {
        val combined = texts.filterNotNull().joinToString(" ")
        val patterns = listOf(
            Regex("(?i)\\bversion\\s*[:-]?\\s*v?(\\d+(?:[.-]\\d+){0,3})\\b"),
            Regex("(?i)\\bv(?:er)?[.\\s]?(\\d+(?:[.-]\\d+){1,3})\\b"),
            Regex("\\b(\\d+\\.\\d+(?:\\.\\d+)?)\\b")
        )
        return patterns.firstNotNullOfOrNull { pattern ->
            pattern.find(combined)?.groupValues?.get(1)?.replace('-', '.')
        }
    }

}
