package mods.sm64cdpy

import java.util.concurrent.atomic.AtomicInteger
import kotlinx.coroutines.CancellationException
import kotlinx.coroutines.delay
import kotlinx.coroutines.runBlocking
import kotlinx.coroutines.withTimeout
import org.junit.Assert.*
import org.junit.Test

class InstallParallelCancellationTest {
    @Test fun `child cancellation stops and joins all writers instead of reporting success`() = runBlocking {
        val active = AtomicInteger()
        val completed = AtomicInteger()
        try {
            withTimeout(2_000) {
                SafZipExtractor.forEachParallel((0..99).toList(), 4) { item ->
                    active.incrementAndGet()
                    try {
                        if (item == 0) throw CancellationException("writer cancelled")
                        delay(10_000)
                        completed.incrementAndGet()
                    } finally { active.decrementAndGet() }
                }
            }
            fail("A cancelled writer cannot produce a successful install")
        } catch (error: CancellationException) {
            assertEquals("writer cancelled", error.message)
        }
        assertEquals(0, active.get())
        assertEquals(0, completed.get())
    }
}
