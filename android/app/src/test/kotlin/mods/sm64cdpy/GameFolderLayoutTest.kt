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
    @Test fun parentGrantResolvesBothSourcesWithOpaqueIds() {
        val externalMods = Node("external-mods")
        val externalPacks = Node("external-packs")
        val game = Node("game-root", mapOf("user" to user, "mods" to externalMods,
            "dynos" to Node("external-dynos", mapOf("packs" to externalPacks))))
        fun resolveGame(id: String) = GameFolderLayout.resolve(game, id, { it.id }, { parent, name -> parent.children[name] })
        assertSame(user, resolveGame("opaque-user"))
        assertSame(mods, resolveGame("opaque-mods"))
        assertSame(packs, resolveGame("opaque-packs"))
        assertSame(externalMods, resolveGame("external-mods"))
        assertSame(externalPacks, resolveGame("external-packs"))
        assertNull(resolveGame("invented-parent/child"))
    }
    @Test fun duplicateNamesFollowEachSubsystemsFirstLoadedSource() {
        val user = listOf("Same" to "user", "UserOnly" to "user")
        val root = listOf("Same" to "root", "RootOnly" to "root")
        val lua = GameFolderLayout.preferred(user, root) { it.first }
        val dynos = GameFolderLayout.preferred(root, user) { it.first }
        assertEquals("user", lua.single { it.first == "Same" }.second)
        assertEquals("root", dynos.single { it.first == "Same" }.second)
        assertEquals(3, lua.size)
        assertEquals(3, dynos.size)
    }
}
