package mods.sm64cdpy

import org.junit.Assert.*
import org.junit.Test

class GameModSelectionTest {
    private val bowser = GameModSelection.Entry("Bowser", true, setOf("moveset"))
    private val unreadable = GameModSelection.Entry("Other", false, emptySet())
    private val mario = GameModSelection.Entry("Mario", true, setOf("moveset"))
    private val entries = listOf(bowser, unreadable, mario)

    @Test fun zeroEnabledModsAllowsActivationDespiteUnreadableDisabledMod() {
        assertNull(GameModSelection.blockedReason(bowser, emptySet(), entries))
    }
    @Test fun onlyEnabledIncompatibilitiesBlock() {
        assertEquals("conflict", GameModSelection.blockedReason(bowser, setOf("Mario"), entries))
        assertNull(GameModSelection.blockedReason(bowser, emptySet(), entries))
    }
    @Test fun unreadableTargetOrActivePeerHasSpecificReason() {
        assertEquals("header", GameModSelection.blockedReason(unreadable, emptySet(), entries))
        assertEquals("active_header", GameModSelection.blockedReason(bowser, setOf("Other"), entries))
        assertNull(GameModSelection.blockedReason(unreadable, setOf("Other"), entries))
    }
    @Test fun noTagsCannotConflict() {
        assertNull(GameModSelection.blockedReason(bowser.copy(tags = emptySet()), setOf("Other"), entries))
    }
}
