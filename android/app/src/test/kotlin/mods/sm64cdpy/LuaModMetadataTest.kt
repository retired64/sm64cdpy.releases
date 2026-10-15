package mods.sm64cdpy

import org.junit.Assert.*
import org.junit.Test

class LuaModMetadataTest {
    @Test fun initialHeaderProvidesDisplayInformationWithoutChangingFilenameIdentity() {
        val metadata = LuaModMetadata.parse("-- name: Display Title\n-- author: Test Author\n-- category: romhack\n-- description: Version 2.4 of this mod\nlocal code = true\n-- author: Ignored", "actual-file.lua")
        assertEquals("Display Title", metadata.name)
        assertEquals("Test Author", metadata.author)
        assertEquals("romhack", metadata.category)
        assertEquals("2.4", metadata.version)
    }
    @Test fun noHeaderDoesNotInventAuthorCategoryOrVersion() {
        val metadata = LuaModMetadata.parse("local code = true\n-- name: Not a header", "actual-file.lua")
        assertNull(metadata.name)
        assertNull(metadata.author)
        assertNull(metadata.category)
        assertNull(metadata.version)
    }
    @Test fun cleansGameColorMarkersAndEscapedNewlines() {
        val metadata = LuaModMetadata.parse("-- name: \\#FF0000\\Red Mod\\\n-- description: First\\nSecond", "file.lua")
        assertEquals("Red Mod", metadata.name)
        assertEquals("First Second", metadata.description)
    }
    @Test fun fieldsAreBoundedAndFirstAuthorWins() {
        val metadata = LuaModMetadata.parse("-- author: ${"a".repeat(200)}\n-- author: Other\n-- category: ${"c".repeat(100)}", "file.lua")
        assertEquals(128, metadata.author!!.length)
        assertEquals(64, metadata.category!!.length)
    }
}
