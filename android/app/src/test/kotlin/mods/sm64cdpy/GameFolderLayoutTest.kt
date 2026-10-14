package mods.sm64cdpy

import org.junit.Assert.*
import org.junit.Test

class GameFolderLayoutTest {
    data class Node(val id: String, val children: Map<String, Node> = emptyMap())
    private val mods = Node("opaque-mods")
    private val packs = Node("opaque-packs")
    private val user = Node("opaque-user", mapOf("mods" to mods,
        "dynos" to Node("opaque-dynos", mapOf("packs" to packs))))
    private fun resolve(id: String) = GameFolderLayout.resolve(user, id, { it.id }, { parent, name -> parent.children[name] })
    @Test fun destinationDocumentsAreResolvedInsteadOfUser() {
        assertSame(mods, resolve("opaque-mods"))
        assertSame(packs, resolve("opaque-packs"))
        assertSame(user, resolve("opaque-user"))
    }
    @Test fun missingOrUnknownChildNeverFallsBackToRoot() {
        assertNull(resolve("opaque-packs/another"))
        assertNull(resolve("opaque-dynos"))
        assertNull(GameFolderLayout.resolve(Node("empty-user"), "opaque-mods", { it.id }, { parent, name -> parent.children[name] }))
    }
    @Test fun destinationsFollowTheGamesLayout() {
        assertEquals(listOf("mods"), GameFolderLayout.destinations["mods"])
        assertEquals(listOf("dynos", "packs"), GameFolderLayout.destinations["dynos"])
    }
}
