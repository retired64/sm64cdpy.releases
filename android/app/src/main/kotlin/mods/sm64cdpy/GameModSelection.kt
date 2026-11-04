package mods.sm64cdpy

/** Disabled unreadable mods cannot conflict; only enabled peers participate. */
internal object GameModSelection {
    data class Entry(val name: String, val readable: Boolean, val tags: Set<String>)

    fun blockedReason(target: Entry, enabled: Set<String>, entries: List<Entry>): String? {
        if (target.name in enabled) return null // Always allow disabling.
        if (!target.readable) return "header"
        if (target.tags.isEmpty()) return null
        val peers = entries.filter { it.name != target.name && it.name in enabled }
        if (peers.any { !it.readable }) return "active_header"
        if (peers.any { it.tags.intersect(target.tags).isNotEmpty() }) return "conflict"
        return null
    }
}
