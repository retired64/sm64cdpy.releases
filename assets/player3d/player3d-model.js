// Read-only GeoLayout/Fast3D extraction, adapted from the existing Android
// parser and launcher-coopdx (Retired64, MIT; see LAUNCHER-LICENSE).
// Keep executable/ROM parsing in the original Android-compatible GameParser.
const mC = 4;
const yC = ['mario_geo', 'luigi_geo', 'toad_player_geo', 'waluigi_geo', 'wario_geo'];
const Fi = ['pants', 'shirt', 'gloves', 'shoes', 'hair', 'skin', 'cap', 'emblem'];
const bC = 127 / 255;
export const identityMatrix = () => [1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1];
const Bo = bytes => new DataView(bytes.buffer, bytes.byteOffset, bytes.byteLength);
const kC = bytes => {
  let text = '';
  for (const byte of bytes) text += String.fromCharCode(byte);
  return btoa(text);
};
// Column-major matrices, matching Three.js and the game's rotate XYZ routine.
export function multiplyMatrices(a, b) {
  const out = new Array(16).fill(0);
  for (let col = 0; col < 4; col++)
    for (let row = 0; row < 4; row++)
      for (let k = 0; k < 4; k++) out[col * 4 + row] += a[k * 4 + row] * b[col * 4 + k];
  return out;
}
export function angleMatrix(ax, ay, az, translation = [0, 0, 0]) {
  const rad = value => value / 65536 * Math.PI * 2;
  const i = Math.sin(rad(ax)), o = Math.cos(rad(ax)), a = Math.sin(rad(ay)), c = Math.cos(rad(ay)),
        l = Math.sin(rad(az)), u = Math.cos(rad(az));
  return [
    c * u, c * l, -a, 0, i * a * u - o * l, i * a * l + o * u, i * c, 0, o * a * u + i * l,
    o * a * l - i * u, o * c, 0, ...translation, 1
  ];
}
export function buildPlayerModel(e, t, n) {
  if (!e.rom) throw new Error('needs the ROM');
  const s = e.d, o = e.dv, i = new Map, r = new Map, a = [];
  for (let m = 0; m < 3; m++) a[m] = {rgb: [0, 0, 0]};
  for (let m = 0; m < Fi.length; m++)
    a[2 * m + 3] = {part: Fi[m], k: 1}, a[2 * m + 4] = {part: Fi[m], k: bC};
  const l = {
    vtx: [],
    texOn: !1,
    scaleS: 1,
    scaleT: 1,
    timg: {va: 0, fmt: 0, siz: 2},
    tiles: Array.from({length: 8}, () => ({tmem: 0, fmt: 0, siz: 2, cms: 0, cmt: 0, w: 32, h: 32})),
    slots: [null, null],
    combine: [0, 0],
    cycle2: !1,
    env: [255, 255, 255, 255],
    prim: [255, 255, 255, 255]
  },
        c = m => m / 24 - 1, u = m => {
          if (!l.texOn) return 0;
          const b = l.tiles[m], w = l.slots[m];
          if (!w) return 0;
          const C = r.get(w.va);
          return (!C || C.w * C.h < b.w * b.h) &&
                     r.set(w.va, {w: b.w, h: b.h, fmt: b.fmt, siz: b.siz}),
                 w.va
        }, d = (m, b, owner = 0, w = 0) => {
          if (!(w > 32 || e.off(m) < 0))
            for (let C = e.off(m), steps = 0; C >= 0 && C + 16 <= s.length && steps < 65536;
                 C += 16, steps++) {
              const S = o.getUint32(C, !0), F = o.getUint32(C + 8, !0), D = S >>> 24;
              if (D === 223) return;
              if (D === 222) {
                if (d(e.ptr(C + 8), b, owner, w + 1), (S >>> 16 & 255) === 1) return
              } else if (D === 1) {
                const x = S >>> 12 & 255, k = (S >>> 1 & 127) - x, R = e.ptr(C + 8), I = e.off(R),
                      L = I < 0 ? e.fromRom(R) : null;
                if (I < 0 && !L) continue;
                for (let H = 0; H < x; H++) {
                  let E, T, U, M, W, J, ie, ce;
                  if (L) {
                    const [$, Z] = L, te = Bo($), oe = Z + H * 16;
                    [E, T, U] = [te.getInt16(oe), te.getInt16(oe + 2), te.getInt16(oe + 4)],
                           [ie, ce] = [te.getInt16(oe + 8), te.getInt16(oe + 10)],
                           [M, W, J] =
                               [te.getInt8(oe + 12), te.getInt8(oe + 13), te.getInt8(oe + 14)]
                  } else {
                    const $ = I + H * 24;
                    [E, T, U] =
                        [o.getFloat32($, !0), o.getFloat32($ + 4, !0), o.getFloat32($ + 8, !0)],
                           [ie, ce] = [o.getInt16($ + 14, !0), o.getInt16($ + 16, !0)],
                           [M, W, J] = [o.getInt8($ + 18), o.getInt8($ + 19), o.getInt8($ + 20)]
                  }
                  l.vtx[k + H] = {
                    p: [
                      E * b[0] + T * b[4] + U * b[8] + b[12],
                      E * b[1] + T * b[5] + U * b[9] + b[13],
                      E * b[2] + T * b[6] + U * b[10] + b[14]
                    ],
                    n: [
                      M * b[0] + W * b[4] + J * b[8], M * b[1] + W * b[5] + J * b[9],
                      M * b[2] + W * b[6] + J * b[10]
                    ],
                    st: [ie, ce]
                  }
                }
              } else if (D === 5 || D === 6)
                h(S, owner), D === 6 && h(F, owner);
              else if (D === 215)
                l.texOn = (S >>> 1 & 127) !== 0, l.scaleS = (F >>> 16 & 65535) / 65536,
                l.scaleT = (F & 65535) / 65536;
              else if (D === 253)
                l.timg = {va: e.ptr(C + 8), fmt: S >>> 21 & 7, siz: S >>> 19 & 3};
              else if (D === 245) {
                const x = l.tiles[F >>> 24 & 7];
                x.tmem = S & 511, x.fmt = S >>> 21 & 7, x.siz = S >>> 19 & 3, x.cmt = F >>> 18 & 3,
                x.cms = F >>> 8 & 3
              } else if (D === 243 || D === 244) {
                const x = F >>> 24 & 7, k = x === 7 ? l.tiles[7].tmem >> 8 : x === 6 ? 1 : 0;
                k < 2 && (l.slots[k] = {...l.timg})
              } else if (D === 242) {
                const x = l.tiles[F >>> 24 & 7];
                x.w = ((F >>> 12 & 4095) - (S >>> 12 & 4095)) / 4 + 1,
                x.h = ((F & 4095) - (S & 4095)) / 4 + 1
              } else if (D === 252)
                l.combine = [S & 16777215, F];
              else if (D === 251 || D === 250) {
                const x = [F >>> 24, F >>> 16 & 255, F >>> 8 & 255, F & 255];
                D === 251 ? l.env = x : l.prim = x
              } else if (D === 227) {
                const x = (S & 255) + 1, k = 32 - (S >>> 8 & 255) - x;
                k <= 20 && k + x > 20 && (l.cycle2 = (F >>> 20 & 3) === 1)
              } else if (D === 220 && (S & 255) === 10) {
                const x = e.at(e.ptr(C + 8));
                a[c((S >>> 8 & 255) * 8)] = { rgb: [s[x], s[x + 1], s[x + 2]] }
              } else if (D === 210 && (S & 255) === 10) {
                const x = c((S >>> 16 & 255) * 8), k = c((S >>> 8 & 255) * 8);
                a[k] = a[x] ?? {
                  rgb: [0, 0, 0]
                }
              }
            }
        };
  function h(m, owner) {
    const b = u(0), w = u(1),
          C = JSON.stringify([owner, b, w, l.combine, l.cycle2, a[1], a[2], l.env, l.prim]);
    let S = i.get(C);
    if (!S) {
      const F = l.tiles[0], D = l.tiles[1];
      S = {
        node: owner,
        pos: [],
        nrm: [],
        uv0: [],
        uv1: [],
        tex: [b, w],
        wrap: [F.cms, F.cmt, D.cms, D.cmt],
        combine: [...l.combine],
        cycle2: l.cycle2,
        diffuse: a[1],
        ambient: a[2],
        env: [...l.env],
        prim: [...l.prim]
      },
      i.set(C, S)
    }
    for (const F of [m >>> 16 & 255, m >>> 8 & 255, m & 255]) {
      const D = l.vtx[F / 2];
      if (!D) return;
      S.pos.push(...D.p);
      const x = Math.hypot(D.n[0], D.n[1], D.n[2]) || 1;
      S.nrm.push(D.n[0] / x, D.n[1] / x, D.n[2] / x);
      for (const [k, R] of [[0, S.uv0], [1, S.uv1]]) {
        const I = l.tiles[k];
        R.push(D.st[0] * l.scaleS / 32 / I.w, D.st[1] * l.scaleT / 32 / I.h)
      }
    }
  }
  const nodes = [{parent: -1, local: identityMatrix(), joint: -1}];
  const pose = [];
  let jointCount = 0;
  function walk(address, context, depth = 0) {
    if (depth > 16) throw new Error('geo_depth');
    let at = e.off(address);
    if (at < 0) throw new Error('geo_address');
    let owner = context.owner, relative = context.relative;
    let pending = identityMatrix(), pendingNode = -1;
    let active = true, nextActive = true, switchPending = false, branch = null;
    const stack = [];
    const short = offset => o.getInt16(offset, true);
    for (let steps = 0; steps < 65536; steps++) {
      if (at < 0 || at + 8 > s.length) throw new Error('geo_bounds');
      const cmd = s[at], flags = s[at + 1];
      if (cmd === 1 || cmd === 3) return;
      if (cmd === 4) {
        stack.push({owner, relative, pending, pendingNode, active, branch});
        if (stack.length > 128) throw new Error('geo_stack');
        if (pendingNode >= 0) {
          owner = pendingNode;
          relative = identityMatrix();
        } else
          relative = multiplyMatrices(relative, pending);
        pending = identityMatrix();
        pendingNode = -1;
        active = nextActive;
        branch = switchPending ? [0, 0] : null;
        switchPending = false;
        at += 8;
        continue;
      }
      if (cmd === 5) {
        const frame = stack.pop();
        if (!frame) return;
        ({owner, relative, pending, pendingNode, active, branch} = frame);
        nextActive = active;
        at += 8;
        continue;
      }
      const hasList = flags & 128 ? 1 : 0;
      const words = {
        0: 2,
        2: 2,
        6: 1,
        7: 1,
        8: 3,
        9: 1,
        10: flags & 1 ? 3 : 2,
        11: 1,
        12: 1,
        13: 2,
        14: 2,
        15: 5,
        16: [4, 2, 2, 1][(flags >> 4) & 3] + hasList,
        17: 2 + hasList,
        18: 2 + hasList,
        19: 3,
        20: 2 + hasList,
        21: 2,
        22: 2,
        23: 1,
        24: 2,
        25: 2,
        26: 2,
        27: 1,
        28: 3,
        29: (flags & 64 ? 4 : 2) + hasList,
        30: 2,
        31: 4,
        32: 1,
        33: 3,
        34: 2,
        35: 2,
        36: flags & 128 ? 8 : 5
      }[cmd];
      if (!words || at + words * 8 > s.length) throw new Error('geo_command');
      nextActive = branch ? active && branch[1]++ === branch[0] : active;
      pending = identityMatrix();
      pendingNode = -1;
      if (cmd === 0 || cmd === 2) {
        if (nextActive) walk(e.ptr(at + 8), {owner, relative}, depth + 1);
        if (cmd === 2 && flags !== 1) return;
      } else if (cmd === 14 || cmd === 34)
        switchPending = true;
      else if (cmd === 19 && nextActive) {
        if (jointCount >= 64) throw new Error('geo_joints');
        const translation = [short(at + 2), short(at + 8), short(at + 10)];
        const rotation = n ? [n(), n(), n()] : [0, 0, 0];
        pose.push(...rotation);
        const local = multiplyMatrices(relative, angleMatrix(0, 0, 0, translation));
        const part = nodes.length;
        nodes.push({parent: owner, local, joint: jointCount++});
        pendingNode = part;
        const list = e.ptr(at + 16);
        if (list) d(list, identityMatrix(), part);
      } else if (cmd === 21 && nextActive) {
        const list = e.ptr(at + 8);
        if (list) d(list, relative, owner);
      } else if (cmd === 29 && nextActive) {
        const scale = offset => o.getUint32(offset, true) / 65536;
        const x = scale(at + 8), y = flags & 64 ? scale(at + 16) : x,
              z = flags & 64 ? scale(at + 24) : x;
        pending = [x, 0, 0, 0, 0, y, 0, 0, 0, 0, z, 0, 0, 0, 0, 1];
        if (hasList) {
          const list = e.ptr(at + (words - 1) * 8);
          if (list) d(list, multiplyMatrices(relative, pending), owner);
        }
      } else if ((cmd === 17 || cmd === 18) && nextActive) {
        const xyz = [short(at + 2), short(at + 8), short(at + 10)];
        pending = cmd === 17 ? angleMatrix(0, 0, 0, xyz) :
                               angleMatrix(...xyz.map(value => value * 32768 / 180));
        if (hasList) {
          const list = e.ptr(at + 16);
          if (list) d(list, multiplyMatrices(relative, pending), owner);
        }
      } else if (cmd === 16)
        nextActive = false;
      at += words * 8;
    }
    throw new Error('geo_steps');
  }
  if (!Number.isInteger(t) || t < 0 || t >= yC.length) throw new Error('model_index');
  walk(e.findActor(yC[t]), {owner: 0, relative: identityMatrix()});
  const g = [];
  for (const [m, {w: b, h: w, fmt: C, siz: S}] of r) {
    const F = e.off(m), D = F < 0 ? e.fromRom(m) : null;
    if (F < 0 && !D) continue;
    const [x, k] = D ? [D[0], D[1]] : [s, F], R = Bo(x), I = new Uint8Array(b * w * 4);
    for (let L = 0; L < b * w; L++) {
      let H = 0, E = 0, T = 0, U = 255;
      if (C === 0 && S === 2) {
        const M = R.getUint16(k + L * 2);
        H = (M >> 11 & 31) * 255 / 31, E = (M >> 6 & 31) * 255 / 31, T = (M >> 1 & 31) * 255 / 31,
        U = M & 1 ? 255 : 0
      } else if (C === 0 && S === 3)
        [H, E, T, U] = [x[k + L * 4], x[k + L * 4 + 1], x[k + L * 4 + 2], x[k + L * 4 + 3]];
      else if (C === 3 && S === 2)
        H = E = T = x[k + L * 2], U = x[k + L * 2 + 1];
      else if (C === 3 && S === 1) {
        const M = x[k + L];
        H = E = T = (M >> 4) * 255 / 15, U = (M & 15) * 255 / 15
      } else if (C === 4 && S === 1)
        H = E = T = U = x[k + L];
      else if (C === 4 && S === 0)
        H = E = T = U = (x[k + (L >> 1)] >> (L & 1 ? 0 : 4) & 15) * 255 / 15;
      else if (C === 3 && S === 0) {
        const M = x[k + (L >> 1)] >> (L & 1 ? 0 : 4) & 15;
        H = E = T = (M >> 1) * 255 / 7, U = M & 1 ? 255 : 0
      }
      I[L * 4] = H, I[L * 4 + 1] = E, I[L * 4 + 2] = T, I[L * 4 + 3] = U
    }
    g.push({id: m, w: b, h: w, rgba: kC(I)})
  }
  return {
    kind: 'coop', version: mC, character: t, posed: !!n, nodes, pose, groups: [...i.values()],
        textures: g
  }
}