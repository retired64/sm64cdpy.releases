package mods.sm64cdpy

import org.junit.Assert.*
import org.junit.Test

class GameDynosConfigTest {
    @Test fun mirrorsLegacyBooleanAndExactCaseRules() {
        assertEquals(setOf("Touch Controls", "Pack", "pack", "Name TRUE"), GameDynosConfig.enabled(
            "dynos-pack: Touch Controls true\ndynos-pack: Disabled false\ndynos-pack: Pack\ndynos-pack: pack\ndynos-pack: Name TRUE\n# dynos-pack: ignored\n"))
        assertNull(GameDynosConfig.identity("dynos-pack:"))
        assertNull(GameDynosConfig.identity("dynos-pack: true"))
    }
    @Test fun removesLegacyAndDuplicateRecordsWithoutChangingLuaOrOtherPacks() {
        val text = "enable-mod: Same\r\ndynos-pack: Same false\r\ndynos-pack:\tSame true\r\ndynos-pack: Other\r\ncustom value"
        val off = "enable-mod: Same\r\ndynos-pack: Other\r\ncustom value"
        assertEquals(off, GameDynosConfig.edit(text, "Same", false))
        val on = "$off\r\ndynos-pack: Same\r\n"
        assertEquals(on, GameDynosConfig.edit(text, "Same", true))
        assertEquals(on, GameDynosConfig.edit(on, "Same", true))
        assertEquals(setOf("Same"), GameModConfig.enabled(on))
    }
    @Test fun rejectsNamesTheGameCannotRoundTrip() {
        for (name in listOf("bad\nname", "../Pack", "Pack true", "Pack false", "true", "false", "two  spaces", "a".repeat(256))) {
            assertFalse(name, GameDynosConfig.validName(name))
        }
        assertTrue(GameDynosConfig.validName("Touch Controls"))
        assertTrue(GameDynosConfig.validName("Pack TRUE"))
    }
    @Test fun followsTheTwentyTokenLimitAndPreservesUnrelatedBytes() {
        val words = (1..20).map { "p$it" }
        assertEquals(words.take(19).joinToString(" "), GameDynosConfig.identity("dynos-pack: " + words.joinToString(" ")))
        assertFalse(GameDynosConfig.validName(words.joinToString(" ")))
        val text = "# untouched\nshow_fps true\nenable-mod: Foo\n"
        assertEquals(text + "dynos-pack: Touch Controls\n", GameDynosConfig.edit(text, "Touch Controls", true))
    }
}
