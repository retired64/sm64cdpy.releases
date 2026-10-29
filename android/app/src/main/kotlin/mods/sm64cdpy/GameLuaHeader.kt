package mods.sm64cdpy

import java.io.InputStream

/** Mirrors mods/mod.c and utils/misc.c::file_get_line (801-byte buffer).
 * Long physical lines are consumed completely and truncated, never rejected.
 * Only first occurrences of useful fields are retained, bounding memory even
 * for arbitrarily long comment headers. Lua is never executed.
 */
internal object GameLuaHeader {
    fun read(input: InputStream): List<String> {
        val stream = input.buffered()
        val fields = linkedMapOf<String, String>()
        val keys = listOf("name", "incompatible", "category", "description", "author", "version")
        while (true) {
            val line = StringBuilder()
            var c = stream.read()
            if (c < 0) break
            while (c >= 0 && c != 10) {
                if (c in 32..126) {
                    if (c == 92) {
                        c = stream.read()
                        if (c < 0 || c == 10) break
                        if (c == 110) c = 10
                    }
                    if (line.length < 800) line.append(c.toChar())
                }
                c = stream.read()
            }
            val value = line.toString()
            if (!value.startsWith("--")) break
            for (key in keys) {
                if (value.startsWith("-- $key:") && key !in fields) {
                    fields[key] = value
                }
            }
        }
        return fields.values.toList()
    }
}
