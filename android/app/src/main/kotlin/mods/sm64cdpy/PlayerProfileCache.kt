package mods.sm64cdpy

import android.content.Context
import android.net.Uri
import org.json.JSONArray
import org.json.JSONObject

/** Disposable display snapshot, never authority for writing sm64config.txt. No SAF listings. */
internal object PlayerProfileCache {
    private const val KEY = "player_display_snapshot_v1"
    private const val MAX_BYTES = 256 * 1024
    private fun prefs(context: Context) = context.getSharedPreferences(ModInstallerPlugin.PREF_NAME, Context.MODE_PRIVATE)
    private fun identity(context: Context): String? {
        val preferences = prefs(context)
        val user = preferences.getString(GameFolderStore.KEY, null) ?: return null
        if (!GameFolderAccess.hasGrant(context, Uri.parse(user), write = true)) return null
        return "${preferences.getString(GameFolderStore.ROOT_KEY, null).orEmpty()}|$user"
    }

    @Synchronized fun read(context: Context): Map<String, Any?> = runCatching {
        val owner = identity(context) ?: run { clear(context); return emptyMap() }
        val text = prefs(context).getString(KEY, null) ?: return emptyMap()
        require(text.length <= MAX_BYTES)
        val value = JSONObject(text)
        require(value.getInt("schema") == 1 && value.getString("owner") == owner)
        @Suppress("UNCHECKED_CAST")
        val snapshot = decode(value.getJSONObject("snapshot")) as Map<String, Any?>
        require(snapshot["status"] == "ready" && snapshot["profile"] is Map<*, *>)
        require((snapshot["revision"] as? String)?.matches(Regex("[a-f0-9]{64}")) == true)
        val profile = snapshot["profile"] as Map<*, *>
        require(profile["name"] is String && ((profile["model"] as? Number)?.toInt() ?: -1) in 0..4)
        val colors = profile["colors"] as? List<*> ?: error("cache")
        require(colors.size == 8 && colors.all { it is Number && it.toLong() in 0L..0xFFFFFFL })
        snapshot
    }.getOrElse { clear(context); emptyMap() }

    @Synchronized fun save(context: Context, snapshot: Map<String, Any?>, includePalettes: Boolean = true) {
        // Cache failures must never turn a verified game write into a reported failure.
        runCatching {
            val owner = identity(context) ?: return
            if (snapshot["status"] != "ready" || snapshot["profile"] == null) return
            val merged = snapshot.toMutableMap()
            if (!includePalettes) merged["palettes"] = read(context)["palettes"] ?: emptyList<Any>()
            val text = JSONObject(mapOf("schema" to 1, "owner" to owner, "snapshot" to merged)).toString()
            if (text.length <= MAX_BYTES) prefs(context).edit().putString(KEY, text).apply()
        }
    }

    @Synchronized fun savePalettes(context: Context, palettes: List<Map<String, Any?>>) {
        val existing = read(context)
        if (existing.isNotEmpty()) save(context, existing + ("palettes" to palettes))
    }

    @Synchronized fun clear(context: Context) { prefs(context).edit().remove(KEY).apply() }

    private fun decode(value: Any?): Any? = when (value) {
        null, JSONObject.NULL -> null
        is JSONObject -> value.keys().asSequence().associateWith { decode(value.get(it)) }
        is JSONArray -> (0 until value.length()).map { decode(value.get(it)) }
        else -> value
    }
}
