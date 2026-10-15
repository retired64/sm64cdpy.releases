package mods.sm64cdpy

import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

class PlayerProfileConfigTest {
    @Test
    fun `reads the exact SM64CoopDX player keys`() {
        val profile = PlayerProfileConfig.parse("""
            coop_player_name LuigiFan
            coop_player_model 0
            coop_player_palette_pants 01 02 ff
            coop_player_palette_cap aa bb cc
        """.trimIndent())
        assertEquals("LuigiFan", profile.name)
        assertEquals(0, profile.model)
        assertEquals(0x0102ff, profile.colors[0])
        assertEquals(0xaabbcc, profile.colors[6])
        assertEquals(8, profile.colors.size)
    }

    @Test
    fun `editing preserves unrelated lines model and CRLF`() {
        val original = "unknown_setting 7\r\ncoop_player_model 4\r\ncoop_player_name Old\r\n# keep me\r\n"
        val colors = List(8) { 0x102030 + it }
        val edited = PlayerProfileConfig.edit(original, "New", colors)
        assertTrue(edited.contains("unknown_setting 7\r\n"))
        assertTrue(edited.contains("coop_player_model 4\r\n"))
        assertTrue(edited.contains("# keep me\r\n"))
        assertEquals("New", PlayerProfileConfig.parse(edited).name)
        assertEquals(colors, PlayerProfileConfig.parse(edited).colors)
    }

    @Test
    fun `palette export round trips all 24 decimal channels`() {
        val colors = listOf(0x0000ff, 0xff0000, 0xffffff, 0x721c0e, 0x730600, 0xfec179, 0xff0000, 0xff0000)
        assertEquals(colors, PlayerProfileConfig.parsePalette(PlayerProfileConfig.palette(colors)))
    }

    @Test
    fun `editing duplicate keys cannot leave a later stale game value`() {
        val original = "coop_player_name First\ncoop_player_name Last\n"
        val edited = PlayerProfileConfig.edit(original, "Mario", List(8) { it })
        assertEquals(2, edited.lineSequence().count { it == "coop_player_name Mario" })
        assertEquals("Mario", PlayerProfileConfig.parse(edited).name)
    }

    @Test
    fun `palette parser follows game decimal and 0x values`() {
        val keys = PlayerProfileConfig.parts.flatMap { part ->
            listOf("${part.uppercase()}_R = 0x10", "${part.uppercase()}_G = 20", "${part.uppercase()}_B = 999")
        }
        val parsed = PlayerProfileConfig.parsePalette("[PALETTE]\n${keys.joinToString("\n")}")!!
        assertTrue(parsed.all { it == 0x1014ff })
    }

    @Test
    fun `name is bounded in UTF8 and rejects config delimiters`() {
        assertTrue(PlayerProfileConfig.validName("Mario"))
        assertTrue(PlayerProfileConfig.validName("á".repeat(31)))
        assertFalse(PlayerProfileConfig.validName("á".repeat(32)))
        assertFalse(PlayerProfileConfig.validName("Mario Player"))
        assertFalse(PlayerProfileConfig.validName("Mario\nLuigi"))
        assertFalse(PlayerProfileConfig.validName("Mario\\"))
        assertFalse(PlayerProfileConfig.validName("Mario😀"))
    }
}
