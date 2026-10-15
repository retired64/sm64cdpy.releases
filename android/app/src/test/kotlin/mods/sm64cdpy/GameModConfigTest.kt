package mods.sm64cdpy

import org.junit.Assert.*
import org.junit.Test

class GameModConfigTest {
    @Test fun gameIdentityUsesExactCaseAndWhitespaceTokenization() {
        assertEquals(setOf("My mod", "single.lua"), GameModConfig.enabled(
            "# enable-mod: ignored\n enable-mod:\tMy  mod\nenable-mod: single.lua\nENABLE-MOD: other\n"))
        assertNull(GameModConfig.identity("enable-mod:"))
        assertEquals("single.lua false", GameModConfig.identity("enable-mod: single.lua false"))
    }
    @Test fun disablesAllDuplicatesWithoutTouchingOtherSettingsOrPacks() {
        val text = "# comment\r\nshow_fps true\r\nenable-mod: My mod\r\ndynos-pack: Pack\r\nenable-mod:\tMy  mod\r\ncustom value"
        assertEquals("# comment\r\nshow_fps true\r\ndynos-pack: Pack\r\ncustom value", GameModConfig.edit(text, "My mod", false))
    }
    @Test fun enablingPreservesUnterminatedLastLineAndUsesExistingLineEnding() {
        assertEquals("# a\r\ncustom value\r\nenable-mod: mod\r\n", GameModConfig.edit("# a\r\ncustom value", "mod", true))
        assertEquals("enable-mod: mod\n", GameModConfig.edit("", "mod", true))
    }
    @Test fun repeatedEnableIsIdempotentAndCaseSensitive() {
        val once = GameModConfig.edit("enable-mod: MOD\n", "mod", true)
        assertEquals(once, GameModConfig.edit(once, "mod", true))
        assertEquals(setOf("MOD", "mod"), GameModConfig.enabled(once))
    }
    @Test fun unsafeOrUnrepresentableIdentitiesAreRejected() {
        for (name in listOf("../mod", ".hidden", "mod\nshow_fps true", "mod\tname", "mod  name", " mod", "a".repeat(256), "mod:bad", "mód")) {
            assertFalse(name, GameModConfig.validName(name))
        }
        assertTrue(GameModConfig.validName("My mod.lua"))
    }
}
