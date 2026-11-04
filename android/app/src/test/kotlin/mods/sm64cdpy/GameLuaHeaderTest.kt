package mods.sm64cdpy

import org.junit.Assert.*
import org.junit.Test

class GameLuaHeaderTest {
    private fun read(text: String) = GameLuaHeader.read(text.byteInputStream())

    @Test fun longDescriptionIsTruncatedAndLaterIncompatibilityStillRead() {
        val header = read("-- description: ${"x".repeat(20000)}\r\n-- incompatible: moveset\nlocal a = 1")
        assertEquals(800, header[0].length)
        assertEquals("-- incompatible: moveset", header[1])
    }

    @Test fun largeHeaderDoesNotRejectOtherwiseValidMod() {
        val header = read(("-- comment\n".repeat(7000)) + "-- name: Day Night\nlocal a = 1")
        assertEquals(listOf("-- name: Day Night"), header)
    }

    @Test fun matchesGameEscapesFilteringAndFirstOccurrence() {
        val header = read("-- name: \\#FF0000\\Red\r\n-- incompatible: first\n-- incompatible: second\n\n-- author: ignored")
        assertEquals("-- name: #FF0000Red", header[0])
        assertEquals(listOf("-- name: #FF0000Red", "-- incompatible: first"), header)
    }

    @Test fun stopsAtCodeAndKeepsMemoryBoundedForRepeatedFields() {
        assertTrue(read("local a = 1\n-- incompatible: ignored").isEmpty())
        assertEquals(1, read("-- author: first\n".repeat(10000)).size)
    }
}
