package mods.sm64cdpy

/** Paths from SM64CoopDX: mods.c / dynos.h. IDs may be opaque provider IDs. */
internal object GameFolderLayout {
    val destinations = mapOf("mods" to listOf("mods"), "dynos" to listOf("dynos", "packs"))
    fun <T> preferred(first: List<T>, second: List<T>, name: (T) -> String): List<T> =
        (first + second).distinctBy(name)
    fun <T> resolve(root: T, wantedId: String, id: (T) -> String, child: (T, String) -> T?): T? {
        if (id(root) == wantedId) return root
        for (path in destinations.values + listOf(listOf("user"), listOf("user", "mods"), listOf("user", "dynos", "packs"))) {
            var candidate: T? = root
            for (name in path) candidate = candidate?.let { child(it, name) }
            if (candidate != null && id(candidate) == wantedId) return candidate
        }
        return null // Never mistake an unresolved child for the tree root.
    }
}
