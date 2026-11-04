// Android-compatible ELF/AArch64 GameParser recovered from the existing local
// bundle. Read-only; no browser/app bootstrap and no remote imports.
// Original and adaptation: Retired64, MIT (see LAUNCHER-LICENSE).
const Bo = e => new DataView(e.buffer, e.byteOffset, e.byteLength),
      xC = e => Uint8Array.from(e, t => t.charCodeAt(0)), SC = e => {
        const t = new Uint8Array(8);
        return new DataView(t.buffer).setBigUint64(0, BigInt(e), !0), t
      };
function ln(e, t, n = 0) {
  const s = t[0], o = e.length - t.length;
  for (let i = e.indexOf(s, n); i >= 0 && i <= o; i = e.indexOf(s, i + 1)) {
    let r = 1;
    for (; r < t.length && e[i + r] === t[r];) r++;
    if (r === t.length) return i
  }
  return -1
}
const Ht = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
function kC(e) {
  let t = '', n = 0;
  for (; n + 2 < e.length; n += 3) {
    const s = e[n] << 16 | e[n + 1] << 8 | e[n + 2];
    t += Ht[s >> 18] + Ht[s >> 12 & 63] + Ht[s >> 6 & 63] + Ht[s & 63]
  }
  if (n < e.length) {
    const s = e[n] << 16 | (e[n + 1] ?? 0) << 8;
    t += Ht[s >> 18] + Ht[s >> 12 & 63], t += n + 1 < e.length ? Ht[s >> 6 & 63] + '=' : '=='
  }
  return t
}
const IC = {
  windows: {
    prologue: [72, 131, 236, 56],
    lea: [72, 141, 13],
    args: [
      {at: [65, 185], arg: 'physSize', len: 6}, {at: [65, 184], arg: 'phys', len: 6},
      {at: [186], arg: 'type', len: 5}, {at: [49, 210], arg: 'type', len: 2, zero: !0},
      {at: [199, 68, 36, 40], arg: 'segSize', len: 8}, {at: [199, 68, 36, 32], arg: 'seg', len: 8}
    ]
  },
  linux: {
    prologue: [243, 15, 30, 250],
    lea: [72, 141, 61],
    args: [
      {at: [65, 185], arg: 'segSize', len: 6}, {at: [65, 184], arg: 'seg', len: 6},
      {at: [69, 49, 192], arg: 'seg', len: 3, zero: !0}, {at: [185], arg: 'physSize', len: 5},
      {at: [186], arg: 'phys', len: 5}, {at: [190], arg: 'type', len: 5},
      {at: [49, 246], arg: 'type', len: 2, zero: !0}
    ]
  }
};
export class GameParser {
  d;
  dv;
  base = 0;
  secs = [];
  rom;
  kind = 'windows';
  rel = new Map;
  syms = new Map;
  queueTargets = [];
  assets = null;
  banks = new Map;
  constructor(t, n) {
    if (this.d = t, this.dv = Bo(t), this.rom = n, this.dv.getUint32(0) === 2135247942) {
      this.readElf();
      return
    }
    const s = this.dv, o = s.getUint32(60, !0);
    if (s.getUint32(o, !0) !== 17744 || s.getUint16(o + 4, !0) !== 34404)
      throw new Error('not a 64-bit Windows program');
    const i = s.getUint16(o + 6, !0), r = s.getUint16(o + 20, !0), a = o + 24;
    this.base = this.u64(a + 24);
    for (let l = 0; l < i; l++) {
      const c = a + r + l * 40;
      this.secs.push({
        name: this.str(c, Math.min(t.indexOf(0, c) < 0 ? c + 8 : t.indexOf(0, c), c + 8)),
        va: s.getUint32(c + 12, !0),
        size: s.getUint32(c + 16, !0),
        raw: s.getUint32(c + 20, !0)
      })
    }
  }
  u64(t) {
    return Number(this.dv.getBigUint64(t, !0))
  }
  str(t, n = this.d.indexOf(0, t)) {
    return String.fromCharCode(...this.d.subarray(t, n))
  }
  readElf() {
    const {d: t, dv: n} = this;
    if (t[4] !== 2 || t[5] !== 1) throw new Error('not a 64-bit little-endian program');
    const s = n.getUint16(18, !0), o = n.getUint16(16, !0);
    if (s === 62) {
      if (o !== 2) throw new Error('position-independent build');
      this.kind = 'linux'
    } else if (s === 183)
      this.kind = 'android';
    else
      throw new Error('not an x86-64 or AArch64 program');
    const i = this.u64(40), r = n.getUint16(58, !0), a = n.getUint16(60, !0),
          l = this.u64(i + n.getUint16(62, !0) * r + 24), c = [];
    for (let u = 0; u < a; u++) {
      const d = i + u * r;
      c.push({
        name: this.str(l + n.getUint32(d, !0)),
        type: n.getUint32(d + 4, !0),
        va: this.u64(d + 16),
        raw: this.u64(d + 24),
        size: this.u64(d + 32),
        link: n.getUint32(d + 40, !0)
      });
      const h = Number(n.getBigUint64(d + 8, !0) & 2n), f = c[c.length - 1];
      h && f.type !== 8 && this.secs.push({name: f.name, va: f.va, raw: f.raw, size: f.size})
    }
    this.kind === 'android' && this.readDynamic(c)
  }
  readDynamic(t) {
    const {dv: n} = this, s = t.find(c => c.name === '.dynsym');
    if (!s) throw new Error('no symbol table');
    const o = t[s.link].raw, i = c => ({
                               name: this.str(o + n.getUint32(s.raw + c * 24, !0)),
                               value: this.u64(s.raw + c * 24 + 8)
                             });
    for (let c = 1; c < s.size / 24; c++) {
      const u = i(c);
      u.value && !this.syms.has(u.name) && this.syms.set(u.name, u.value)
    }
    let r = -1;
    for (const c of t.filter(u => u.type === 4))
      for (let u = c.raw; u < c.raw + c.size; u += 24) {
        const d = this.u64(u), h = n.getBigUint64(u + 8, !0), f = Number(n.getBigInt64(u + 16, !0)),
              p = Number(h & 0xffffffffn), g = Number(h >> 32n);
        p === 1027                  ? this.rel.set(d, f) :
            p === 257 || p === 1025 ? this.rel.set(d, i(g).value + f) :
                                      p === 1026 && i(g).name === 'rom_assets_queue' && (r = d)
      }
    const a = this.syms.get('rom_assets_queue');
    a && this.queueTargets.push(a);
    const l = this.secs.find(c => c.name === '.plt');
    if (l && r >= 0)
      for (let c = l.raw; c + 8 <= l.raw + l.size; c += 4) {
        const u = n.getUint32(c, !0), d = n.getUint32(c + 4, !0);
        if (!((u & 2667577375) >>> 0 !== 2415919120 || (d & 4290774015) >>> 0 !== 4181721617) &&
            Lc(u, this.va(c)) + (d >>> 10 & 4095) * 8 === r) {
          this.queueTargets.push(this.va(c));
          break
        }
      }
  }
  off(t) {
    const n = t - this.base;
    for (const s of this.secs)
      if (n >= s.va && n < s.va + s.size) return s.raw + n - s.va;
    return -1
  }
  va(t) {
    for (const n of this.secs)
      if (t >= n.raw && t < n.raw + n.size) return this.base + n.va + t - n.raw;
    return -1
  }
  ptr(t) {
    return this.kind === 'android' ? this.rel.get(this.va(t)) ?? this.u64(t) : this.u64(t)
  }
  at(t) {
    const n = this.off(t);
    if (n < 0) throw new Error(`address ${t.toString(16)} is outside the file`);
    return n
  }
  findActor(t) {
    const n = i => this.off(i) >= 0 && this.d[this.off(i)] === 11, s = this.syms.get(t);
    if (s !== void 0 && n(s)) return s;
    const o = xC(`${t}\0`);
    for (let i = ln(this.d, o); i >= 0; i = ln(this.d, o, i + 1)) {
      const r = this.va(i);
      if (r < 0) continue;
      if (this.kind === 'android') {
        for (const [l, c] of this.rel)
          if (c === r && n(this.rel.get(l + 8) ?? -1)) return this.rel.get(l + 8);
        continue
      }
      const a = SC(r);
      for (let l = ln(this.d, a); l >= 0; l = ln(this.d, a, l + 8)) {
        if (l % 8) continue;
        const c = this.ptr(l + 8);
        if (n(c)) return c
      }
    }
    throw new Error(`${t} not found in the game`)
  }
  romAssets() {
    if (this.assets) return this.assets;
    const t = this.kind === 'android' ? this.armAssets() : this.x86Assets();
    return this.assets = t.sort((n, s) => n.ptr - s.ptr)
  }
  x86Assets() {
    const t = [], n = this.secs.find(u => u.name === '.text'), {d: s, dv: o} = this,
          {prologue: i, lea: r, args: a} = IC[this.kind === 'linux' ? 'linux' : 'windows'],
          l = (u, d) => d.every((h, f) => s[u + f] === h), c = Uint8Array.from(i);
    if (n) {
      const u = n.raw + n.size;
      for (let d = ln(s, c, n.raw); d >= 0 && d < u; d = ln(s, c, d + 1)) {
        const h = {};
        let f = d + i.length;
        for (let p = 0; p < 8; p++) {
          if (l(f, r)) {
            h.ptr = this.va(f + 7) + o.getInt32(f + 3, !0), f += 7;
            continue
          }
          const g = a.find(m => l(f, m.at));
          if (!g) break;
          h[g.arg] = g.zero ? 0 : o.getUint32(f + g.at.length, !0), f += g.len
        }
        (s[f] === 232 || s[f] === 233) && Object.keys(h).length === 6 && h.type <= 1 && t.push(h)
      }
    }
    return t
  }
  armAssets() {
    const t = [], n = this.secs.find(i => i.name === '.text');
    if (!n || !this.queueTargets.length) return t;
    const {dv: s} = this, o = n.raw + n.size;
    for (let i = n.raw; i < o; i += 4) {
      const r = s.getUint32(i, !0);
      if ((r & 2080374784) >>> 0 !== 335544320 || !this.queueTargets.includes(this.va(i) + TC(r)))
        continue;
      let a = i - 4;
      for (let u = 0; u < 24 && a > n.raw; u++, a -= 4) {
        const d = s.getUint32(a, !0);
        if (d === 3596551104 || (d & 2080374784) >>> 0 === 335544320) break
      }
      const l = new Array(32).fill(void 0);
      l[31] = 0;
      let c = !0;
      for (let u = a + 4; u < i && c; u += 4) c = this.step(s.getUint32(u, !0), this.va(u), l);
      !c || l[1] > 1 || [0, 1, 2, 3, 4, 5].some(u => l[u] === void 0) ||
          t.push({ptr: l[0], type: l[1], phys: l[2], physSize: l[3], seg: l[4], segSize: l[5]})
    }
    return t
  }
  step(t, n, s) {
    const o = t & 31, i = t >>> 5 & 31, r = t >>> 16 & 31, a = t >>> 31 === 1,
          l = u => a ? u : u >>> 0, c = u => (t & u) >>> 0;
    if (c(2667577344) === 2415919104)
      s[o] = Lc(t, n);
    else if (c(2139095040) === 285212672 || c(2139095040) === 1358954496) {
      const u = t >>> 10 & 4095, d = t >>> 22 & 1 ? u * 4096 : u;
      if (s[i] === void 0) return !1;
      s[o] = l(t >>> 30 & 1 ? s[i] - d : s[i] + d)
    } else if (c(4290772992) === 4181721088) {
      if (s[i] === void 0 || (s[o] = this.rel.get(s[i] + (t >>> 10 & 4095) * 8), s[o] === void 0))
        return !1
    } else if (c(2139095040) === 1384120320)
      s[o] = (t >>> 5 & 65535) * 2 ** ((t >>> 21 & 3) * 16);
    else if (c(2139095040) === 1920991232) {
      const u = (t >>> 21 & 3) * 16;
      if (s[o] === void 0) return !1;
      s[o] = (s[o] & ~(65535 << u) | (t >>> 5 & 65535) << u) >>> 0
    } else if (c(2139095040) === 310378496)
      s[o] = ~((t >>> 5 & 65535) << (t >>> 21 & 3) * 16) >>> 0;
    else if (c(4286578688) === 838860800) {
      if (s[i] === void 0) return !1;
      s[o] = (s[i] | BC(t >>> 22 & 1, t >>> 16 & 63, t >>> 10 & 63)) >>> 0
    } else if (c(4292934656) === 704643072) {
      if (s[i] === void 0 || s[r] === void 0) return !1;
      s[o] = (s[i] | s[r]) >>> 0
    } else if (c(2145451008) === 184549376) {
      if (s[i] === void 0 || s[r] === void 0) return !1;
      s[o] = l(s[i] + s[r])
    } else
      return !1;
    return !0
  }
  fromRom(t) {
    if (!this.rom) return null;
    for (const n of this.romAssets()) {
      const s = n.type === 0 ? n.segSize / 16 * 24 : n.segSize;
      if (t < n.ptr || t >= n.ptr + s) continue;
      let o = this.banks.get(n.phys);
      if (!o) {
        const r = this.rom;
        o = String.fromCharCode(...r.subarray(n.phys, n.phys + 4)) === 'MIO0' ?
            _d(r, n.phys) :
            r.subarray(n.phys, n.phys + n.physSize),
        this.banks.set(n.phys, o)
      }
      const i = n.type === 0 ? (t - n.ptr) / 24 * 16 : t - n.ptr;
      return [o, n.seg + i, n.type === 0]
    }
    return null
  }
}
function Lc(e, t) {
  let n = (e >>> 5 & 524287) << 2 | e >>> 29 & 3;
  return n & 1048576 && (n -= 2097152), Math.floor(t / 4096) * 4096 + n * 4096
}
function TC(e) {
  let t = e & 67108863;
  return t & 33554432 && (t -= 67108864), t * 4
}
function BC(e, t, n) {
  const o = 1 << 31 - Math.clz32(e << 6 | ~n & 63), i = o - 1, r = n & i, a = t & i;
  let l = 2 ** (r + 1) - 1 >>> 0;
  l = o === 32 ? (l >>> a | l << 32 - a) >>> 0 : DC(l, o, a);
  let c = 0;
  for (let u = 0; u < 32; u += o) c |= l << u;
  return c >>> 0
}
function DC(e, t, n) {
  const s = (1 << t) - 1;
  return (e >>> n | e << t - n) & s
}
// Bounded MIO0 decoder for ROM-backed vertices and textures.
function _d(bytes, offset) {
  const view = Bo(bytes);
  const requireRange = (at, size) => {
    if (at < 0 || at + size > bytes.length) throw new Error('mio_bounds');
  };
  requireRange(offset, 16);
  const size = view.getUint32(offset + 4);
  if (size > 16 * 1024 * 1024) throw new Error('mio_size');
  let packed = offset + view.getUint32(offset + 8), raw = offset + view.getUint32(offset + 12),
      mask = offset + 16;
  const output = new Uint8Array(size);
  let written = 0, bits = 0, flags = 0;
  while (written < size) {
    if (!bits) {
      requireRange(mask, 4);
      flags = view.getUint32(mask);
      mask += 4;
      bits = 32;
    }
    if (flags & 0x80000000) {
      requireRange(raw, 1);
      output[written++] = bytes[raw++];
    } else {
      requireRange(packed, 2);
      const pair = view.getUint16(packed);
      packed += 2;
      const count = (pair >> 12) + 3, distance = (pair & 4095) + 1;
      if (distance > written || written + count > size) throw new Error('mio_backref');
      for (let i = 0; i < count; i++) {
        output[written] = output[written - distance];
        written++;
      }
    }
    flags = flags << 1 >>> 0;
    bits--;
  }
  return output;
}

// A fresh consumable centre-idle pose reader is required for each character.
export function animationForRom(bytes) {
  try {
    const view = Bo(bytes), table = 0x4ec000, id = 0xc5;
    const at = table + view.getUint32(table + 8 + id * 8);
    const values = at + view.getUint32(at + 12), indices = at + view.getUint32(at + 16);
    const frame = Math.max(0, view.getInt16(at + 4));
    const pose = [];
    for (let channel = 3; channel < 63; channel++) {
      const entry = indices + channel * 4, length = view.getUint16(entry),
            offset = view.getUint16(entry + 2);
      if (!length) throw new Error('pose_channel');
      pose.push(view.getInt16(values + 2 * (offset + Math.min(frame, length - 1))));
    }
    let next = 0;
    return () => {
      if (next >= pose.length) throw new Error('pose_joints');
      return pose[next++];
    };
  } catch {
    return null;
  }
}
