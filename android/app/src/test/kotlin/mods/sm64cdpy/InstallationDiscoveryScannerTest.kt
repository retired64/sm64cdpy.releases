package mods.sm64cdpy

import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Test

class InstallationDiscoveryScannerTest {
    @Test
    fun `reads only initial comment header and cleans color codes`() {
        val metadata = InstallationDiscoveryScanner.parseLuaHeader(
            """
            -- name: \\#FF0000\\Fixture Mod\\
            -- category: romhack
            -- author: Test Author
            -- description: Release version 1-2\\nSecond line
            local ignored = true
            -- name: Must Not Replace
            """.trimIndent(),
            "fallback"
        )

        assertEquals("Fixture Mod", metadata.name)
        assertEquals("romhack", metadata.category)
        assertEquals("Test Author", metadata.author)
        assertEquals("1.2", metadata.version)
    }

    @Test
    fun `falls back to filename version without inventing metadata`() {
        val metadata = InstallationDiscoveryScanner.parseLuaHeader(
            "return { name = 'not a header' }",
            "Example v2.4"
        )

        assertNull(metadata.name)
        assertNull(metadata.category)
        assertEquals("2.4", metadata.version)
    }

    @Test
    fun `removes inconsistent color markers and escaped newlines`() {
        assertEquals(
            "Red text next",
            InstallationDiscoveryScanner.cleanLuaText(
                "\\\\#ff0000\\\\Red text\\\\ \\nnext"
            )
        )
    }
}
