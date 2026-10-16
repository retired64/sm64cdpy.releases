package mods.sm64cdpy

/** Lossless editor for the Player fields written by SM64CoopDX's configfile.c. */
internal object PlayerProfileConfig {
    val parts = listOf("pants", "shirt", "gloves", "shoes", "hair", "skin", "cap", "emblem")
    private val defaults = listOf(0x0000ff, 0xff0000, 0xffffff, 0x721c0e, 0x730600, 0xfec179, 0xff0000, 0xff0000)
    private val colorPattern = Regex("^\\s*coop_player_palette_(${parts.joinToString("|")})\\s+([0-9a-fA-F]{1,2})\\s+([0-9a-fA-F]{1,2})\\s+([0-9a-fA-F]{1,2})\\s*$")
    private val namePattern = Regex("^\\s*coop_player_name(?:\\s+(.*?))?\\s*$")
    private val modelPattern = Regex("^\\s*coop_player_model\\s+(\\d+)\\s*$")
    // Direct subset of djui_unicode.c's sSmCodeGlyphs covering the Latin
    // characters used by the app's supported languages. ASCII is accepted by
    // the game from '!' upward. Unknown Unicode is rejected instead of being
    // saved and reset to Player by SM64CoopDX on its next load.
    private const val supportedLatin = "ÁÅÂÀÃÄÇÉÊÈËÍÎÌÏÑÓÔÒÕÖÚÛÙÜÝŸáåâàãäçéêèëíîìïñóôòõöúûùüýÿæÆœŒðÐøØß¡¿"

    data class Profile(val name: String, val model: Int, val colors: List<Int>)

    fun parse(text: String): Profile {
        var name = "Player"
        var model = 0
        val colors = defaults.toMutableList()
        for (line in text.lineSequence()) {
            namePattern.matchEntire(line)?.let { name = it.groupValues[1].trim().ifBlank { "Player" } }
            modelPattern.matchEntire(line)?.let { model = it.groupValues[1].toIntOrNull() ?: 0 }
            colorPattern.matchEntire(line)?.let { match ->
                val part = parts.indexOf(match.groupValues[1])
                val channels = (2..4).map { match.groupValues[it].toInt(16) }
                colors[part] = (channels[0] shl 16) or (channels[1] shl 8) or channels[2]
            }
        }
        return Profile(name, model, colors)
    }

    fun edit(text: String, name: String, model: Int, colors: List<Int>): String {
        require(validName(name) && model in 0..4 && colors.size == parts.size && colors.all { it in 0..0xffffff }) { "invalid" }
        val newline = if (text.contains("\r\n")) "\r\n" else "\n"
        val trailing = text.endsWith("\n") || text.endsWith("\r")
        val lines = text.split(Regex("\\r?\\n")).toMutableList()
        if (trailing && lines.lastOrNull()?.isEmpty() == true) lines.removeAt(lines.lastIndex)
        val replacements = linkedMapOf<String, String>()
        replacements["coop_player_name"] = "coop_player_name $name"
        replacements["coop_player_model"] = "coop_player_model $model"
        for ((index, part) in parts.withIndex()) {
            val color = colors[index]
            replacements["coop_player_palette_$part"] = "coop_player_palette_$part %02x %02x %02x".format(
                color shr 16 and 255, color shr 8 and 255, color and 255)
        }
        val seen = mutableSetOf<String>()
        for (index in lines.indices) {
            val key = lines[index].trimStart().substringBefore(' ').substringBefore('\t')
            val value = replacements[key] ?: continue
            seen.add(key)
            lines[index] = value
        }
        for ((key, value) in replacements) if (key !in seen) lines += value
        return lines.joinToString(newline) + if (trailing || text.isEmpty()) newline else ""
    }

    fun validName(value: String): Boolean {
        val bytes = value.toByteArray(Charsets.UTF_8)
        if (value.isEmpty() || bytes.size !in 1..63 || value.any {
                it.isWhitespace() || it == '\u0000' || (it.code >= 128 && it !in supportedLatin)
            }) return false
        var escaped = false
        var onlyEscapes = true
        var slashCount = 0
        for (character in value) {
            if (character == '\\') { escaped = !escaped; slashCount++ }
            else if (!escaped) onlyEscapes = false
        }
        return !onlyEscapes && slashCount % 2 == 0
    }

    fun parsePalette(text: String): List<Int>? {
        val values = mutableMapOf<String, Int>()
        var section = false
        for (raw in text.lineSequence()) {
            val line = raw.trim()
            if (line.startsWith('[') && line.endsWith(']')) { section = line.equals("[PALETTE]", true); continue }
            if (!section || '=' !in line) continue
            val key = line.substringBefore('=').trim().uppercase()
            val rawValue = line.substringAfter('=').trim().lowercase()
            if (!Regex("(?:0x)?[0-9a-f]+", RegexOption.IGNORE_CASE).matches(rawValue)) continue
            // player_palette.c uses strtol(value, NULL, 0): 0x is hex,
            // a leading zero is octal, and parsing stops at the first invalid digit.
            val (digits, radix) = when {
                rawValue.startsWith("0x") -> rawValue.drop(2).takeWhile { it.isDigit() || it in 'a'..'f' } to 16
                rawValue.length > 1 && rawValue.startsWith('0') -> rawValue.takeWhile { it in '0'..'7' } to 8
                else -> rawValue.takeWhile { it.isDigit() } to 10
            }
            val value = (digits.toIntOrNull(radix) ?: 0).coerceAtMost(255)
            values[key] = value
        }
        val result = mutableListOf<Int>()
        for (part in parts) {
            val prefix = part.uppercase()
            val r = values["${prefix}_R"] ?: return null
            val g = values["${prefix}_G"] ?: return null
            val b = values["${prefix}_B"] ?: return null
            result += (r shl 16) or (g shl 8) or b
        }
        return result
    }

    fun palette(colors: List<Int>): String {
        require(colors.size == parts.size && colors.all { it in 0..0xffffff }) { "invalid" }
        return buildString {
            append("[PALETTE]\n")
            for ((index, part) in parts.withIndex()) {
                val prefix = part.uppercase()
                val color = colors[index]
                append("${prefix}_R = ${color shr 16 and 255}\n")
                append("${prefix}_G = ${color shr 8 and 255}\n")
                append("${prefix}_B = ${color and 255}\n")
            }
        }
    }
}
