package mods.sm64cdpy

import org.junit.Assert.assertArrayEquals
import org.junit.Assert.assertEquals
import org.junit.Assert.assertThrows
import org.junit.Assume.assumeTrue
import org.junit.Test
import java.io.ByteArrayInputStream
import java.io.ByteArrayOutputStream
import java.io.File
import java.io.FileInputStream
import java.io.FileOutputStream
import java.io.InputStream
import java.security.MessageDigest
import java.util.concurrent.CancellationException

class RomByteOrderConverterTest {
    private val z64 = byteArrayOf(0x80.toByte(), 0x37, 0x12, 0x40, 1, 2, 3, 4, 9, 8, 7, 6)

    @Test fun `normalizes every supported order`() {
        val v64 = z64.copyOf().also { pairs(it) }
        val n64 = z64.copyOf().also { words(it) }
        listOf(z64, v64, n64).forEach { source ->
            val output = ByteArrayOutputStream()
            val result = RomByteOrderConverter.convertToZ64(ChunkedInputStream(source), output, source.size, md5(z64))
            assertArrayEquals(z64, output.toByteArray())
            assertEquals(source.size.toLong(), result.bytesWritten)
        }
    }

    @Test fun `rejects unknown short extra and incompatible input`() {
        assertThrows(RomPreparationException::class.java) { convert(byteArrayOf(1, 2, 3, 4), "00") }
        assertThrows(RomPreparationException::class.java) { convert(z64.copyOf(z64.size - 1), md5(z64)) }
        assertThrows(RomPreparationException::class.java) { convert(z64 + 1, md5(z64)) }
        assertThrows(RomPreparationException::class.java) { convert(z64, "00") }
    }

    @Test fun `honors cancellation between reads`() {
        var checks = 0
        assertThrows(CancellationException::class.java) {
            RomByteOrderConverter.convertToZ64(ChunkedInputStream(z64), ByteArrayOutputStream(), z64.size, md5(z64), cancelled = { ++checks > 3 })
        }
    }

    @Test fun `makes progress when a provider temporarily returns zero bytes`() {
        val output = ByteArrayOutputStream()
        RomByteOrderConverter.convertToZ64(ZeroThenDataInputStream(z64), output, z64.size, md5(z64))
        assertArrayEquals(z64, output.toByteArray())
    }

    @Test fun `optional private dumps normalize to the same verified bytes`() {
        val sourcePath = System.getenv("SM64_TEST_SWAPPED_ROM")
        val expectedPath = System.getenv("SM64_TEST_Z64_ROM")
        assumeTrue("Private ROM fixtures were not provided", sourcePath != null && expectedPath != null)
        val output = File.createTempFile("sm64-normalized-", ".z64")
        try {
            val result = FileInputStream(sourcePath!!).use { source ->
                FileOutputStream(output).use { target ->
                    RomByteOrderConverter.convertToZ64(source, target)
                }
            }
            assertEquals(RomByteOrder.V64, result.sourceFormat)
            assertEquals(sha256(File(expectedPath!!)), sha256(output))
        } finally {
            output.delete()
        }
    }

    private fun convert(source: ByteArray, hash: String) = RomByteOrderConverter.convertToZ64(ByteArrayInputStream(source), ByteArrayOutputStream(), z64.size, hash)
    private fun md5(bytes: ByteArray) = MessageDigest.getInstance("MD5").digest(bytes).joinToString("") { "%02x".format(it.toInt() and 0xff) }
    private fun sha256(file: File): String = FileInputStream(file).use { source ->
        val digest = MessageDigest.getInstance("SHA-256")
        val buffer = ByteArray(64 * 1024)
        while (true) {
            val count = source.read(buffer)
            if (count < 0) break
            if (count > 0) digest.update(buffer, 0, count)
        }
        digest.digest().joinToString("") { "%02x".format(it.toInt() and 0xff) }
    }
    private fun pairs(bytes: ByteArray) { for (i in bytes.indices step 2) { val a = bytes[i]; bytes[i] = bytes[i + 1]; bytes[i + 1] = a } }
    private fun words(bytes: ByteArray) { for (i in bytes.indices step 4) { val a = bytes[i]; val b = bytes[i + 1]; bytes[i] = bytes[i + 3]; bytes[i + 1] = bytes[i + 2]; bytes[i + 2] = b; bytes[i + 3] = a } }

    private class ChunkedInputStream(private val bytes: ByteArray) : InputStream() {
        private var offset = 0
        override fun read(): Int = if (offset >= bytes.size) -1 else bytes[offset++].toInt() and 0xff
        override fun read(target: ByteArray, off: Int, len: Int): Int {
            if (offset >= bytes.size) return -1
            val count = minOf(len, (offset % 3) + 1, bytes.size - offset)
            bytes.copyInto(target, off, offset, offset + count)
            offset += count
            return count
        }
    }

    private class ZeroThenDataInputStream(private val bytes: ByteArray) : InputStream() {
        private var offset = 0
        private var returnZero = true
        override fun read(): Int = if (offset >= bytes.size) -1 else bytes[offset++].toInt() and 0xff
        override fun read(target: ByteArray, off: Int, len: Int): Int {
            if (offset >= bytes.size) return -1
            if (returnZero) {
                returnZero = false
                return 0
            }
            returnZero = true
            val count = minOf(len, 2, bytes.size - offset)
            bytes.copyInto(target, off, offset, offset + count)
            offset += count
            return count
        }
    }
}
