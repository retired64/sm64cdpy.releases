package mods.sm64cdpy

import java.io.ByteArrayOutputStream
import java.net.DatagramPacket
import java.net.DatagramSocket
import java.net.InetAddress
import java.net.InetSocketAddress
import java.net.SocketException
import java.util.ArrayDeque
import java.util.LinkedHashMap
import java.util.concurrent.Executors
import java.util.concurrent.ScheduledExecutorService
import java.util.concurrent.ScheduledFuture
import java.util.concurrent.TimeUnit
import java.util.zip.DataFormatException
import java.util.zip.Deflater
import java.util.zip.Inflater

/** UDP bridge compatible with the SM64CoopDX connection helper protocol. */
internal class CoopGameBridge(private val listener: Listener) {
    interface Listener {
        fun onPacket(peer: String, data: ByteArray)
        fun onGameSeen()
        fun onLog(message: String)
    }

    private class Link {
        var downAt = -1L
        var touch: ScheduledFuture<*>? = null
        var flush: ScheduledFuture<*>? = null
        val kept = LinkedHashMap<Int, ByteArray>()
        var keptBytes = 0
        val pending = ArrayDeque<ByteArray>()
    }

    companion object {
        const val GAME_PORT = 7777
        const val MAX_PACKET = 4096
        private const val KEEP_BYTES = 2 * 1024 * 1024
        private const val FLUSH_BYTES = 32 * 1024
        private const val FLUSH_MS = 50L
        private const val TOUCH_MS = 2_000L
        private val LOOPBACK = InetAddress.getByAddress(byteArrayOf(127, 0, 0, 1))
        private val LOOPBACK6 = InetAddress.getByAddress(ByteArray(16).apply { this[15] = 1 })
        private val STILL_HERE = stillHere()

        fun gameHosting(): Boolean = try {
            DatagramSocket(null).use { probe ->
                probe.reuseAddress = false
                probe.bind(InetSocketAddress(LOOPBACK, GAME_PORT))
            }
            false
        } catch (_: SocketException) {
            true
        }

        private fun stillHere(): ByteArray {
            val body = byteArrayOf(15, 0, 0, 0, -1)
            var checksum = 0L
            body.forEachIndexed { index, byte ->
                checksum = (checksum xor ((byte.toLong() and 0xff) shl ((index % 4) * 8))) and 0xffffffffL
            }
            checksum = checksum.inv() and 0xffffffffL
            val packet = ByteArray(9)
            body.copyInto(packet)
            repeat(4) { packet[5 + it] = (checksum ushr (it * 8)).toByte() }
            val deflater = Deflater()
            return try {
                deflater.setInput(packet)
                deflater.finish()
                val output = ByteArrayOutputStream()
                val buffer = ByteArray(64)
                while (!deflater.finished()) output.write(buffer, 0, deflater.deflate(buffer))
                output.toByteArray()
            } finally {
                deflater.end()
            }
        }
    }

    private val peers = mutableMapOf<String, DatagramSocket>()
    private val links = mutableMapOf<String, Link>()
    private val joinSockets = arrayListOf<DatagramSocket>()
    private var gameSocket: DatagramSocket? = null
    private var gameAddress: InetSocketAddress? = null
    private var mode: String? = null
    private var seen = false
    private var timer: ScheduledExecutorService? = null
    var toGameCount = 0L
        private set
    var toPageCount = 0L
        private set

    @Synchronized
    fun start(nextMode: String): Int {
        stop()
        require(nextMode == "host" || nextMode == "join")
        mode = nextMode
        seen = false
        toGameCount = 0
        toPageCount = 0
        timer = Executors.newSingleThreadScheduledExecutor { runnable ->
            Thread(runnable, "coop-link-timer").apply { isDaemon = true }
        }
        if (nextMode == "host") return GAME_PORT

        val ipv4 = DatagramSocket(null).apply { reuseAddress = false }
        try {
            ipv4.bind(InetSocketAddress(LOOPBACK, GAME_PORT))
        } catch (_: SocketException) {
            listener.onLog("join: port 7777 is taken, using another")
            ipv4.bind(InetSocketAddress(LOOPBACK, 0))
        }
        val port = ipv4.localPort
        joinListen(ipv4, "join")
        try {
            val ipv6 = DatagramSocket(null).apply {
                reuseAddress = false
                bind(InetSocketAddress(LOOPBACK6, port))
            }
            joinListen(ipv6, "join6")
        } catch (error: Exception) {
            listener.onLog("join: no IPv6 loopback (${error.message}), use 127.0.0.1")
        }
        return port
    }

    @Synchronized
    fun openPeer(peer: String) {
        if (mode != "host" || peers.containsKey(peer)) return
        val socket = DatagramSocket(InetSocketAddress(LOOPBACK, 0))
        peers[peer] = socket
        listen(socket, peer.take(6)) { packet ->
            if (packet.address.isLoopbackAddress && packet.port == GAME_PORT) {
                fromGame(peer, packet.copyBytes())
            }
        }
    }

    @Synchronized
    fun closePeer(peer: String) {
        forget(peer)
        peers.remove(peer)?.close()
    }

    @Synchronized
    fun fromRemote(peer: String, data: ByteArray) {
        if (data.size <= MAX_PACKET) toGame(peer, data)
    }

    @Synchronized
    fun setLink(peer: String, up: Boolean) {
        if (mode == null || (mode == "host" && !peers.containsKey(peer))) return
        val link = links.getOrPut(peer) { Link() }
        if (!up) {
            if (link.downAt >= 0) return
            link.downAt = System.currentTimeMillis()
            toGame(peer, STILL_HERE)
            link.touch = timer?.scheduleWithFixedDelay(
                { synchronized(this) { if (link.downAt >= 0) toGame(peer, STILL_HERE) } },
                TOUCH_MS,
                TOUCH_MS,
                TimeUnit.MILLISECONDS,
            )
            listener.onLog("${peer.take(6)}: link down, holding their place in the game")
            return
        }
        if (link.downAt < 0) return
        val seconds = (System.currentTimeMillis() - link.downAt) / 1000.0
        link.touch?.cancel(false)
        link.touch = null
        link.downAt = -1
        link.pending.addAll(link.kept.values)
        link.kept.clear()
        link.keptBytes = 0
        listener.onLog("${peer.take(6)}: link back after %.1f s, sending ${link.pending.size} kept packets".format(seconds))
        scheduleFlush(peer, link)
    }

    @Synchronized
    fun stop() {
        links.keys.toList().forEach(::forget)
        peers.values.forEach { it.close() }
        peers.clear()
        joinSockets.forEach { it.close() }
        joinSockets.clear()
        gameSocket = null
        gameAddress = null
        mode = null
        timer?.shutdownNow()
        timer = null
    }

    @Synchronized
    fun active(): Boolean = mode != null

    private fun joinListen(socket: DatagramSocket, name: String) {
        joinSockets.add(socket)
        listen(socket, name) { packet ->
            if (!packet.address.isLoopbackAddress) return@listen
            gameAddress = InetSocketAddress(packet.address, packet.port)
            gameSocket = socket
            if (!seen) {
                seen = true
                listener.onGameSeen()
            }
            fromGame("host", packet.copyBytes())
        }
    }

    private fun listen(socket: DatagramSocket, name: String, onPacket: (DatagramPacket) -> Unit) {
        Thread({
            val packet = DatagramPacket(ByteArray(65_536), 65_536)
            while (!socket.isClosed) {
                try {
                    packet.length = 65_536
                    socket.receive(packet)
                    synchronized(this) { if (!socket.isClosed) onPacket(packet) }
                } catch (error: Exception) {
                    if (socket.isClosed) return@Thread
                    listener.onLog("$name: socket error (${error.message})")
                }
            }
        }, "coop-bridge-$name").apply { isDaemon = true }.start()
    }

    private fun toGame(peer: String, data: ByteArray) {
        try {
            if (mode == "host") {
                peers[peer]?.send(DatagramPacket(data, data.size, LOOPBACK, GAME_PORT))
            } else if (mode == "join") {
                val socket = gameSocket
                val address = gameAddress
                if (socket != null && address != null) socket.send(DatagramPacket(data, data.size, address))
            }
            toGameCount++
        } catch (error: Exception) {
            listener.onLog("${peer.take(6)}: send to game failed (${error.message})")
        }
    }

    private fun fromGame(peer: String, data: ByteArray) {
        links[peer]?.takeIf { it.downAt >= 0 }?.let { keep(it, data) }
        toPageCount++
        listener.onPacket(peer, data)
    }

    private fun keep(link: Link, data: ByteArray) {
        val inflater = Inflater()
        try {
            inflater.setInput(data)
            val decoded = ByteArray(MAX_PACKET)
            val count = inflater.inflate(decoded)
            if (!inflater.finished() || count !in 3..MAX_PACKET) return
            val id = ((decoded[2].toInt() and 0xff) shl 8) or (decoded[1].toInt() and 0xff)
            if (id == 0) return
            link.kept.remove(id)?.let { link.keptBytes -= it.size }
            link.kept[id] = data.copyOf()
            link.keptBytes += data.size
            val iterator = link.kept.entries.iterator()
            while (link.keptBytes > KEEP_BYTES && iterator.hasNext()) {
                link.keptBytes -= iterator.next().value.size
                iterator.remove()
            }
        } catch (_: DataFormatException) {
        } finally {
            inflater.end()
        }
    }

    private fun scheduleFlush(peer: String, link: Link) {
        if (link.flush != null || link.pending.isEmpty()) return
        link.flush = timer?.scheduleWithFixedDelay({
            synchronized(this) {
                var bytes = 0
                while (link.pending.isNotEmpty() && bytes < FLUSH_BYTES) {
                    val packet = link.pending.removeFirst()
                    bytes += packet.size
                    toGame(peer, packet)
                }
                if (link.pending.isEmpty()) {
                    link.flush?.cancel(false)
                    link.flush = null
                }
            }
        }, 0, FLUSH_MS, TimeUnit.MILLISECONDS)
    }

    private fun forget(peer: String) {
        links.remove(peer)?.let {
            it.touch?.cancel(false)
            it.flush?.cancel(false)
        }
    }

    private fun DatagramPacket.copyBytes(): ByteArray = data.copyOfRange(offset, offset + length)
}
