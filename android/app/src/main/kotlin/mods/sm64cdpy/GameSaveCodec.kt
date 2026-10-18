package mods.sm64cdpy

import java.nio.ByteBuffer
import java.nio.ByteOrder

/** US/JP 512-byte EEPROM layout from save_file.[ch]. Never mirrors independent copies. */
internal class GameSaveCodec(input: ByteArray) {
    val bytes = input.copyOf()
    val order: ByteOrder
    init {
        require(bytes.size == 512) { "size" }
        val signatures = (0..7).map { it * 56 + 52 to 0x4441 } + listOf(476 to 0x4849, 508 to 0x4849)
        fun matches(order: ByteOrder) = signatures.count { (at, magic) ->
            ByteBuffer.wrap(bytes).order(order).getShort(at).toInt() and 65535 == magic
        }
        val big = matches(ByteOrder.BIG_ENDIAN)
        val little = matches(ByteOrder.LITTLE_ENDIAN)
        require(big == 0 || little == 0) { "format" }
        require(big + little > 0 || bytes.all { it == 0.toByte() }) { "format" }
        order = if (little > big) ByteOrder.LITTLE_ENDIAN else ByteOrder.BIG_ENDIAN
    }
    private fun buffer() = ByteBuffer.wrap(bytes).order(order)
    private fun offset(slot: Int, bank: Int): Int {
        require(slot in 0..3 && bank in 0..1) { "invalid" }
        return (slot * 2 + bank) * 56
    }
    private fun checksum(at: Int, size: Int) = (at until at + size - 2).sumOf { bytes[it].toInt() and 255 } and 65535
    private fun sign(at: Int, size: Int, magic: Int) {
        buffer().putShort(at + size - 4, magic.toShort())
        buffer().putShort(at + size - 2, checksum(at, size).toShort())
    }
    fun valid(slot: Int, bank: Int): Boolean {
        val at = offset(slot, bank)
        return buffer().getShort(at + 52).toInt() and 65535 == 0x4441 &&
            buffer().getShort(at + 54).toInt() and 65535 == checksum(at, 56)
    }
    fun empty(slot: Int, bank: Int) = bytes.sliceArray(offset(slot, bank) until offset(slot, bank) + 56).all { it == 0.toByte() }
    fun flags(slot: Int, bank: Int) = buffer().getInt(offset(slot, bank) + 8)
    fun stars(slot: Int, bank: Int) = (0..24).map { bytes[offset(slot, bank) + 12 + it].toInt() and 127 }
    fun coins(slot: Int, bank: Int) = (0..14).map {
        val raw = bytes[offset(slot, bank) + 37 + it].toInt() and 255
        raw.coerceAtLeast(if (bytes[offset(slot, bank) + 12 + it].toInt() and 64 != 0) 100 else 0)
    }
    fun cannons(slot: Int, bank: Int) = (1..15).map { bytes[offset(slot, bank) + 12 + it].toInt() and 128 != 0 }
    fun total(slot: Int, bank: Int) = stars(slot, bank).sumOf { Integer.bitCount(it) } + Integer.bitCount(flags(slot, bank) ushr 24 and 127)
    fun edit(slot: Int, bank: Int, stars: List<Int>, coins: List<Int>, cannons: List<Boolean>, castle: Int, unlocks: Int) {
        require(valid(slot, bank) || empty(slot, bank)) { "format" }
        require(stars.size == 25 && coins.size == 15 && cannons.size == 15 && castle in 0..31) { "invalid" }
        require(stars.withIndex().all { (i, value) -> value in 0..((1 shl maxStars[i]) - 1) } && coins.all { it in 0..255 }) { "invalid" }
        val at = offset(slot, bank)
        stars.forEachIndexed { i, value -> bytes[at + 12 + i] = ((bytes[at + 12 + i].toInt() and 128) or value).toByte() }
        cannons.forEachIndexed { i, value -> val p = at + 13 + i; bytes[p] = ((bytes[p].toInt() and 127) or if (value) 128 else 0).toByte() }
        coins.forEachIndexed { i, value -> bytes[at + 37 + i] = value.coerceAtLeast(if (stars[i] and 64 != 0) 100 else 0).toByte() }
        val mask = 0x0010ffff
        require(unlocks and mask.inv() == 0) { "invalid" }
        val preserved = flags(slot, bank) and (mask or 0x1f000000).inv()
        buffer().putInt(at + 8, preserved or unlocks or (castle shl 24) or 1)
        sign(at, 56, 0x4441)
    }
    fun copy(slot: Int, destination: Int) {
        require(slot != destination) { "invalid" }
        require((0..1).all { valid(slot, it) || empty(slot, it) }) { "format" }
        for (bank in 0..1) bytes.copyInto(bytes, offset(destination, bank), offset(slot, bank), offset(slot, bank) + 56)
        sign(offset(destination, 0), 56, 0x4441)
        touchAges(destination)
    }
    fun erase(slot: Int) {
        bytes.fill(0, offset(slot, 0), offset(slot, 0) + 112)
        sign(offset(slot, 0), 56, 0x4441)
        touchAges(slot)
    }
    private fun touchAges(slot: Int) {
        // Main menu copies follow the game's own save_main_menu_data policy.
        // CoopDX disables vanilla menu recovery: a new save can legitimately
        // retain an all-zero menu. Its zero ages need no update.
        if (bytes.sliceArray(448 until 480).all { it == 0.toByte() }) return
        require(buffer().getShort(476).toInt() and 65535 == 0x4849 &&
            buffer().getShort(478).toInt() and 65535 == checksum(448, 32)) { "format" }
        var changed = false
        for (course in 0..14) {
            val shift = course * 2
            val age = buffer().getInt(448 + slot * 4) ushr shift and 3
            if (age == 0) continue
            changed = true
            for (other in 0..3) {
                val at = 448 + other * 4
                val old = buffer().getInt(at)
                val value = old ushr shift and 3
                val next = if (other == slot) 0 else if (value < age) value + 1 else value
                buffer().putInt(at, (old and (3 shl shift).inv()) or (next shl shift))
            }
        }
        if (!changed) return
        sign(448, 32, 0x4849)
        bytes.copyInto(bytes, 480, 448, 480)
    }
    companion object { val maxStars = List(15) { 7 } + listOf(1,1,1,2,1,1,1,1,1,0) }
}
