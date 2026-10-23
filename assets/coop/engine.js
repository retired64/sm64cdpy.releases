(() => {
  "use strict";
  const WORKER = "https://coop-mod-loader-relay.jehu-cl.workers.dev";
  const ICE = [
    { urls: "stun:stun.l.google.com:19302" },
    { urls: "stun:stun.cloudflare.com:3478" },
  ];
  const encoder = new TextEncoder();
  const HELLO = 1, PING = 2, PONG = 3, LEAVE = 4;
  const VERSION = 2, MAX_PACKET = 4096, MAX_BUFFERED = 65536;

  const api = {
    publish: state => NativeCoop.publish(JSON.stringify(state)),
    packet: (peer, bytes) => NativeCoop.packet(peer, to64(bytes), Date.now()),
    open: peer => NativeCoop.peerOpen(peer),
    close: peer => NativeCoop.peerClose(peer),
    link: (peer, up) => NativeCoop.setLink(peer, up),
    log: line => NativeCoop.log(String(line).slice(0, 500)),
    fail: line => NativeCoop.failed(String(line).slice(0, 300)),
  };
  function binary(bytes) {
    let value = "";
    for (let i = 0; i < bytes.length; i++) value += String.fromCharCode(bytes[i]);
    return value;
  }
  const to64 = bytes => btoa(binary(bytes));
  const from64 = value => Uint8Array.from(atob(value), c => c.charCodeAt(0));
  const randomId = () => binary(crypto.getRandomValues(new Uint8Array(20)).map(v => 65 + (v % 26)));
  function socketUrl(infoHash) {
    const hex = [...infoHash].map(c => c.charCodeAt(0).toString(16).padStart(2, "0")).join("");
    return `${WORKER.replace(/^http/, "ws")}/room/${hex}`;
  }
  async function room(code) {
    const input = await crypto.subtle.importKey("raw", encoder.encode(code), "PBKDF2", false, ["deriveBits"]);
    const bits = new Uint8Array(await crypto.subtle.deriveBits({
      name: "PBKDF2", hash: "SHA-256", salt: encoder.encode("coop-mod-loader/room/v2"), iterations: 600000,
    }, input, 416));
    return {
      infoHash: binary(bits.subarray(0, 20)),
      key: await crypto.subtle.importKey("raw", bits.slice(20), "AES-GCM", false, ["encrypt", "decrypt"]),
    };
  }
  async function seal(roomKey, text) {
    const iv = crypto.getRandomValues(new Uint8Array(12));
    const body = new Uint8Array(await crypto.subtle.encrypt({ name: "AES-GCM", iv }, roomKey.key, encoder.encode(text)));
    const result = new Uint8Array(iv.length + body.length);
    result.set(iv); result.set(body, iv.length);
    return to64(result);
  }
  async function unseal(roomKey, text) {
    try {
      const value = from64(text);
      const clear = await crypto.subtle.decrypt({ name: "AES-GCM", iv: value.slice(0, 12) }, roomKey.key, value.slice(12));
      return new TextDecoder().decode(clear);
    } catch (_) { return null; }
  }
  const sdpField = (sdp, field) => sdp.match(new RegExp(`^a=${field}:(.+)$`, "m"))?.[1]?.trim() ?? "";

  class Signalling {
    constructor(infoHash, peerId, events) {
      this.infoHash = infoHash; this.peerId = peerId; this.events = events;
      this.offers = []; this.retry = 1000; this.closed = false;
    }
    start() { this.connect(); this.timer = setInterval(() => this.announce(), 15000); }
    connect() {
      if (this.closed) return;
      const socket = new WebSocket(socketUrl(this.infoHash));
      this.socket = socket;
      socket.onopen = () => { this.retry = 1000; this.announce(); this.events.status(1); };
      socket.onmessage = event => {
        let message;
        try { message = JSON.parse(String(event.data)); } catch (_) { return; }
        if (message.info_hash !== this.infoHash || message.peer_id === this.peerId) return;
        const peer = String(message.peer_id);
        if (message.offer?.sdp) this.events.offer(peer, message.offer.sdp, String(message.offer_id));
        if (message.answer?.sdp) this.events.answer(peer, message.answer.sdp, String(message.offer_id));
      };
      socket.onclose = () => {
        this.events.status(0);
        if (this.closed) return;
        const delay = this.retry; this.retry = Math.min(delay * 2, 10000);
        setTimeout(() => this.connect(), delay);
      };
      socket.onerror = () => {};
    }
    setOffers(offers, publish = true) {
      this.offers = offers.map(v => ({ offer: { type: "offer", sdp: v.sdp }, offer_id: v.id }));
      if (publish) this.announce();
    }
    announce() {
      if (this.socket?.readyState !== WebSocket.OPEN) return;
      this.socket.send(JSON.stringify({
        action: "announce", info_hash: this.infoHash, peer_id: this.peerId,
        numwant: this.offers.length || 10, uploaded: 0, downloaded: 0,
        left: 1, event: "started", offers: this.offers,
      }));
    }
    answer(peer, offerId, sdp) {
      if (this.socket?.readyState !== WebSocket.OPEN) return;
      this.socket.send(JSON.stringify({
        action: "announce", info_hash: this.infoHash, peer_id: this.peerId,
        to_peer_id: peer, answer: { type: "answer", sdp }, offer_id: offerId,
      }));
    }
    close() { this.closed = true; clearInterval(this.timer); this.socket?.close(); }
  }

  function gather(pc, timeout, relayAvailable) {
    return new Promise(resolve => {
      let srflx = false, relay = false, settle;
      const done = () => {
        clearTimeout(limit); clearTimeout(settle);
        pc.removeEventListener("icecandidate", candidate);
        pc.removeEventListener("icegatheringstatechange", state);
        resolve();
      };
      const limit = setTimeout(done, timeout);
      const candidate = event => {
        srflx ||= event.candidate?.type === "srflx";
        relay ||= event.candidate?.type === "relay";
        if ((relay || (srflx && !relayAvailable)) && settle === undefined) settle = setTimeout(done, 300);
      };
      const state = () => { if (pc.iceGatheringState === "complete") done(); };
      pc.addEventListener("icecandidate", candidate);
      pc.addEventListener("icegatheringstatechange", state);
    });
  }
  async function route(pc) {
    try {
      const stats = await pc.getStats(); let selected, answer = null;
      stats.forEach(v => { if (v.type === "transport" && v.selectedCandidatePairId) selected = v.selectedCandidatePairId; });
      stats.forEach(v => {
        if (v.type !== "candidate-pair" || !(v.id === selected || (!selected && v.nominated && v.state === "succeeded"))) return;
        const local = stats.get(v.localCandidateId), remote = stats.get(v.remoteCandidateId);
        answer = local?.candidateType === "relay" || remote?.candidateType === "relay" ? "relay" : "direct";
      });
      return answer;
    } catch (_) { return null; }
  }

  class Session {
    constructor(params) {
      this.mode = params.mode; this.code = params.code; this.relayOnly = !!params.relayOnly;
      this.self = randomId(); this.slots = new Map(); this.offers = new Map(); this.owners = new Map();
      this.state = { mode: this.mode, code: this.code, phase: "starting", friends: [], trackers: 0, message: null };
      this.started = Date.now(); this.gameIn = false; this.stopped = false;
    }
    publish(patch = {}) {
      this.state = { ...this.state, ...patch, friends: [...this.slots.values()].filter(v => v.joined).map(v => ({
        id: v.id, route: v.route, reconnecting: v.lostAt !== null, game: v.game,
      })) };
      api.publish(this.state);
    }
    slot(id) {
      const value = { id, link: null, joined: false, modern: false, leaving: false, lastHeard: Date.now(), lastPing: 0, lostAt: null, route: null, game: null, restarting: false };
      this.slots.set(id, value); return value;
    }
    async start() {
      this.room = await room(this.code);
      this.signal = new Signalling(this.room.infoHash, this.self, {
        offer: (peer, sdp, id) => this.offer(peer, sdp, id).catch(e => api.log(`offer failed (${e.message})`)),
        answer: (_peer, sdp, id) => this.answer(sdp, id).catch(e => api.log(`answer failed (${e.message})`)),
        status: trackers => this.publish({ trackers }),
      });
      this.signal.start();
      if (this.mode === "host") this.publish({ phase: "waiting" });
      else { this.publish({ phase: "connecting" }); await this.makeOffer(this.slot("host")); }
    }
    async iceServers() {
      if (this.ice && Date.now() - this.ice.at < 1800000) return this.ice.servers;
      let servers = ICE;
      try {
        const data = await (await fetch(WORKER, { signal: AbortSignal.timeout(4000) })).json();
        servers = [...ICE, ...(data.iceServers ?? [])];
      } catch (_) { api.log("relay logins unavailable; direct routes only"); }
      this.ice = { servers, at: Date.now() }; return servers;
    }
    link(slot, fingerprint = "") {
      const pc = new RTCPeerConnection({ iceServers: this.ice?.servers ?? ICE, iceTransportPolicy: this.relayOnly ? "relay" : "all" });
      const link = { pc, dc: null, fingerprint, generation: 0, answered: 0 };
      pc.onconnectionstatechange = () => this.check(slot);
      pc.oniceconnectionstatechange = () => this.check(slot);
      return link;
    }
    wire(slot, link, channel) {
      link.dc = channel; channel.binaryType = "arraybuffer";
      channel.onopen = async () => {
        if (this.slots.get(slot.id) !== slot || slot.link !== link) return;
        this.control(link, [HELLO, VERSION]);
        if (this.mode === "host" && !slot.joined) api.open(slot.id);
        slot.joined = true; slot.lostAt = null; slot.route = await route(link.pc);
        this.publish({ phase: "connected", message: null });
      };
      channel.onmessage = event => this.receive(slot, link, new Uint8Array(event.data));
      channel.onclose = () => this.check(slot);
    }
    control(link, bytes) { if (link?.dc?.readyState === "open") link.dc.send(new Uint8Array(bytes)); }
    receive(slot, link, bytes) {
      if (bytes.length > MAX_PACKET || this.slots.get(slot.id) !== slot) return;
      slot.lastHeard = Date.now();
      if (bytes[0] === 120) api.packet(slot.id, bytes);
      else if (bytes[0] === HELLO) slot.modern = true;
      else if (bytes[0] === PING && bytes.length >= 5) {
        this.control(link, [PONG, bytes[1], bytes[2], bytes[3], bytes[4]]);
        if (bytes.length >= 6 && slot.game !== (bytes[5] === 1)) { slot.game = bytes[5] === 1; this.publish(); }
      } else if (bytes[0] === LEAVE) { slot.leaving = true; this.drop(slot); return; }
      if (slot.lostAt !== null) { slot.lostAt = null; api.link(slot.id, true); this.publish({ phase: "connected" }); }
    }
    nativePacket(peer, bytes) {
      const channel = this.slots.get(peer)?.link?.dc;
      if (channel?.readyState === "open" && channel.bufferedAmount < MAX_BUFFERED) channel.send(bytes);
    }
    async makeOffer(slot) {
      await this.iceServers(); slot.link?.pc.close();
      const link = this.link(slot); slot.link = link;
      this.wire(slot, link, link.pc.createDataChannel("game", { ordered: false, maxRetransmits: 0 }));
      const waiting = gather(link.pc, slot.joined ? 3000 : 5000, this.ice.servers.length > ICE.length);
      await link.pc.setLocalDescription(await link.pc.createOffer({ iceRestart: slot.joined })); await waiting;
      const generation = ++link.generation, encrypted = await seal(this.room, link.pc.localDescription.sdp);
      const ids = Array.from({ length: 6 }, randomId);
      ids.forEach(id => this.offers.set(id, { link, generation }));
      while (this.offers.size > 24) this.offers.delete(this.offers.keys().next().value);
      this.signal.setOffers(ids.map(id => ({ id, sdp: encrypted })));
    }
    async answer(encrypted, id) {
      if (this.mode !== "join") return;
      const found = this.offers.get(id), link = found?.link;
      if (!found || !link || found.generation !== link.generation || link.pc.signalingState !== "have-local-offer") return;
      const sdp = await unseal(this.room, encrypted);
      if (!sdp || link.answered === link.generation) return;
      link.answered = link.generation; this.signal.setOffers([], false);
      await link.pc.setRemoteDescription({ type: "answer", sdp });
    }
    async offer(peer, encrypted, offerId) {
      if (this.mode !== "host" || this.stopped) return;
      const sdp = await unseal(this.room, encrypted); if (!sdp) return;
      const fingerprint = sdpField(sdp, "fingerprint"); if (!fingerprint) return;
      const owner = this.owners.get(fingerprint); if (owner && owner !== peer) return;
      this.owners.set(fingerprint, peer);
      while (this.owners.size > 1024) this.owners.delete(this.owners.keys().next().value);
      let slot = this.slots.get(peer);
      if (!slot && this.slots.size >= 15) return;
      if (!slot) slot = this.slot(peer);
      slot.link?.pc.close();
      const link = this.link(slot, fingerprint); slot.link = link;
      link.pc.ondatachannel = event => this.wire(slot, link, event.channel);
      await link.pc.setRemoteDescription({ type: "offer", sdp });
      const waiting = gather(link.pc, slot.joined ? 3000 : 5000, this.ice?.servers.length > ICE.length);
      await link.pc.setLocalDescription(await link.pc.createAnswer()); await waiting;
      this.signal.answer(peer, offerId, await seal(this.room, link.pc.localDescription.sdp));
    }
    check(slot) {
      if (!slot.joined || this.stopped) return;
      const state = slot.link?.pc.connectionState, channel = slot.link?.dc;
      const up = channel?.readyState === "open" && state !== "failed" && state !== "closed" && (!slot.modern || Date.now() - slot.lastHeard <= 2000);
      if (!up && slot.lostAt === null) { slot.lostAt = Date.now(); api.link(slot.id, false); this.publish({ phase: "reconnecting" }); }
    }
    tick() {
      if (this.stopped) return; const now = Date.now();
      if (this.mode === "join" && this.state.phase === "connecting" && now - this.started > 90000) return this.fail("Couldn’t find your friend. Check the code and that they are hosting.");
      for (const slot of [...this.slots.values()]) {
        if (slot.link?.dc?.readyState === "open" && slot.modern && now - slot.lastPing >= 500) {
          slot.lastPing = now; const time = performance.now() >>> 0;
          this.control(slot.link, [PING, time & 255, (time >>> 8) & 255, (time >>> 16) & 255, time >>> 24, this.gameIn ? 1 : 0]);
        }
        this.check(slot);
        if (slot.lostAt !== null && now - slot.lostAt > 60000) this.drop(slot);
        else if (this.mode === "join" && slot.lostAt !== null && now - slot.lostAt > 6000 && !slot.restarting) {
          slot.restarting = true; this.makeOffer(slot).finally(() => { slot.restarting = false; });
        }
      }
    }
    drop(slot) {
      if (this.slots.get(slot.id) !== slot) return;
      this.slots.delete(slot.id); slot.link?.pc.close(); api.close(slot.id);
      if (this.mode === "host") this.publish({ phase: this.slots.size ? "connected" : "waiting" });
      else this.fail(slot.leaving ? "Your friend stopped hosting." : "The connection was lost.");
    }
    fail(message) { this.publish({ phase: "failed", message }); api.fail(message); }
    async stop() {
      if (this.stopped) return;
      for (const slot of this.slots.values()) this.control(slot.link, [LEAVE]);
      await new Promise(resolve => setTimeout(resolve, 120)); this.stopped = true; this.signal?.close();
      for (const slot of this.slots.values()) { slot.link?.pc.close(); api.close(slot.id); }
      this.slots.clear(); this.publish({ phase: "stopped" });
    }
  }

  let active = null;
  window.coopEngine = {
    async start(params) { try { if (active) await active.stop(); active = new Session(params); await active.start(); } catch (e) { api.fail(e?.message ?? String(e)); } },
    async stop() { const old = active; active = null; if (old) await old.stop(); },
    tick() { active?.tick(); },
    setGameIn(value) { if (active) active.gameIn = !!value; },
    onGameSeen() { if (active) active.gameIn = true; },
    onNativeLog(message) { api.log(message); },
    onNativePacket(peer, value) { active?.nativePacket(peer, from64(value)); },
  };
  NativeCoop.ready();
})();
