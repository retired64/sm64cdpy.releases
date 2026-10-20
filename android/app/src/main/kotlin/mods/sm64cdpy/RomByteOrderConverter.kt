package mods.sm64cdpy

import java.io.InputStream
import java.io.OutputStream
import java.security.MessageDigest
import java.util.concurrent.CancellationException

internal enum class RomByteOrder(val wireName: String) {
    Z64("z64"), V64("v64"), N64("n64");

    companion object {
        fun detect(header: ByteArray): RomByteOrder = when (header.toList()) {
            listOf(0x80.toByte(), 0x37, 0x12, 0x40) -> Z64
            listOf(0x37, 0x80.toByte(), 0x40, 0x12) -> V64
            listOf(0x40, 0x12, 0x37, 0x80.toByte()) -> N64
            else -> throw RomPreparationException("unrecognized", "Unrecognized Nintendo 64 byte order")
        }
    }
}

internal class RomPreparationException(val code: String, message: String) : Exception(message)

internal data class RomConversionResult(
    val sourceFormat: RomByteOrder,
    val bytesWritten: Long,
    val md5: String,
)

/** Streaming normalizer. Memory remains bounded regardless of provider behavior. */
internal object RomByteOrderConverter {
    private const val BUFFER_SIZE = 64 * 1024

    fun convertToZ64(
        input: InputStream,
        output: OutputStream,
        expectedSize: Int = MarioRomDecoder.ROM_SIZE,
        expectedMd5: String = MarioRomDecoder.ROM_MD5,
        cancelled: () -> Boolean = { false },
        onProgress: (Long, Long) -> Unit = { _, _ -> },
    ): RomConversionResult {
        require(expectedSize >= 4 && expectedSize % 4 == 0)
        val buffer = ByteArray(BUFFER_SIZE)
        readExactly(input, buffer, 0, 4, cancelled)
        val format = RomByteOrder.detect(buffer.copyOfRange(0, 4))
        val digest = MessageDigest.getInstance("MD5")
        var written = 0L

        while (written < expectedSize) {
            checkCancelled(cancelled)
            val target = minOf(buffer.size, expectedSize - written.toInt())
            val prefix = if (written == 0L) 4 else 0
            if (target > prefix) readExactly(input, buffer, prefix, target - prefix, cancelled)
            transform(buffer, target, format)
            output.write(buffer, 0, target)
            digest.update(buffer, 0, target)
            written += target
            onProgress(written, expectedSize.toLong())
        }
        checkCancelled(cancelled)
        if (input.read() != -1) throw RomPreparationException("wrong_size", "ROM is larger than 8 MiB")
        output.flush()
        val md5 = digest.digest().joinToString("") { "%02x".format(it.toInt() and 0xff) }
        if (!md5.equals(expectedMd5, ignoreCase = true)) {
            throw RomPreparationException("incompatible", "ROM does not match the supported original US release")
        }
        return RomConversionResult(format, written, md5)
    }

    private fun readExactly(input: InputStream, buffer: ByteArray, offset: Int, length: Int, cancelled: () -> Boolean) {
        var cursor = offset
        val end = offset + length
        while (cursor < end) {
            checkCancelled(cancelled)
            val count = input.read(buffer, cursor, end - cursor)
            if (count < 0) throw RomPreparationException("wrong_size", "ROM ended before 8 MiB")
            if (count == 0) {
                val single = input.read()
                if (single < 0) throw RomPreparationException("wrong_size", "ROM ended before 8 MiB")
                buffer[cursor++] = single.toByte()
            } else {
                cursor += count
            }
        }
    }

    private fun transform(buffer: ByteArray, count: Int, format: RomByteOrder) {
        when (format) {
            RomByteOrder.Z64 -> Unit
            RomByteOrder.V64 -> {
                var index = 0
                while (index < count) {
                    val first = buffer[index]
                    buffer[index] = buffer[index + 1]
                    buffer[index + 1] = first
                    val third = buffer[index + 2]
                    buffer[index + 2] = buffer[index + 3]
                    buffer[index + 3] = third
                    index += 4
                }
            }
            RomByteOrder.N64 -> {
                var index = 0
                while (index < count) {
                    val first = buffer[index]
                    val second = buffer[index + 1]
                    buffer[index] = buffer[index + 3]
                    buffer[index + 1] = buffer[index + 2]
                    buffer[index + 2] = second
                    buffer[index + 3] = first
                    index += 4
                }
            }
        }
    }

    private fun checkCancelled(cancelled: () -> Boolean) {
        if (cancelled()) throw CancellationException("ROM preparation cancelled")
    }
}
