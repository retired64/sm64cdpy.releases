// Idle animation extraction adapted from launcher-coopdx, Retired64 (MIT).
// Only local, validated USA ROM bytes are read. No ROM data ships in assets.
export const CLIP_VERSION = 2;
export const ANIMATION_JOINTS = 20;
const TABLE = 0x4ec000;
const IDS = [[0xc3, "idle-left"], [0xc4, "idle-right"], [0xc5, "idle-center"]];

function base64(bytes) {
  let text = "";
  for (const byte of bytes) text += String.fromCharCode(byte);
  return btoa(text);
}

export function readIdleClips(bytes) {
  const data = new DataView(bytes.buffer, bytes.byteOffset, bytes.byteLength);
  function range(at, size) {
    if (!Number.isSafeInteger(at) || at < 0 || at + size > data.byteLength) {
      throw new Error("animation_bounds");
    }
  }
  range(TABLE, 8);
  const count = data.getUint32(TABLE);
  const clips = IDS.map(([id, name]) => {
    if (id >= count) throw new Error("animation_table");
    const entry = TABLE + 8 + id * 8;
    range(entry, 8);
    const at = TABLE + data.getUint32(entry);
    range(at, 24);
    const flags = data.getUint16(at);
    const divisor = data.getInt16(at + 2);
    const start = data.getInt16(at + 4);
    const end = data.getInt16(at + 8);
    const joints = data.getInt16(at + 10);
    const frames = end - start;
    if (start < 0 || frames <= 0 || frames > 600 || joints !== ANIMATION_JOINTS) {
      throw new Error("animation_header");
    }
    const values = at + data.getUint32(at + 12);
    const indices = at + data.getUint32(at + 16);
    range(values, 2);
    range(indices, (3 + ANIMATION_JOINTS * 3) * 4);
    function channel(index, frame) {
      const address = indices + index * 4;
      const length = data.getUint16(address);
      const offset = data.getUint16(address + 2);
      if (!length) throw new Error("animation_channel");
      // Validate the complete channel, not just the sampled first frame.
      range(values + offset * 2, length * 2);
      const sample = values + (offset + Math.min(frame, length - 1)) * 2;
      return data.getInt16(sample);
    }
    const rotations = new Uint8Array(frames * ANIMATION_JOINTS * 3 * 2);
    const translations = new Uint8Array(frames * 3 * 2);
    const rot = new DataView(rotations.buffer), trans = new DataView(translations.buffer);
    const factor = divisor > 0 ? 189 / divisor : 1;
    for (let frame = 0; frame < frames; frame++) {
      for (let jointAxis = 0; jointAxis < ANIMATION_JOINTS * 3; jointAxis++) {
        rot.setInt16((frame * ANIMATION_JOINTS * 3 + jointAxis) * 2,
          channel(jointAxis + 3, start + frame), true);
      }
      for (let axis = 0; axis < 3; axis++) {
        const value = channel(axis, start + frame) * factor;
        // Match Go math.Round for negative half-integers too.
        const rounded = Math.sign(value) * Math.floor(Math.abs(value) + 0.5);
        if (rounded < -32768 || rounded > 32767) throw new Error("animation_translation");
        trans.setInt16((frame * 3 + axis) * 2, rounded, true);
      }
    }
    return {id: name, frames, fps: 30, loop: !(flags & 1),
      rot: base64(rotations), trans: base64(translations)};
  });
  return {kind: "coop-clips", version: CLIP_VERSION, joints: ANIMATION_JOINTS,
    sequence: IDS.map(([, name]) => name), clips};
}

export function decodeClip(clip, joints) {
  if (!Number.isInteger(joints) || joints < 1 || joints > 64 ||
      !Number.isInteger(clip.frames) || clip.frames < 1 || clip.frames > 600 ||
      !Number.isFinite(clip.fps) || clip.fps <= 0 || clip.fps > 120) {
    throw new Error("animation_clip");
  }
  function decode(text, count) {
    const raw = atob(text);
    if (raw.length !== count * 2) throw new Error("animation_length");
    const out = new Int16Array(count);
    for (let i = 0; i < count; i++) {
      out[i] = ((raw.charCodeAt(i * 2) | raw.charCodeAt(i * 2 + 1) << 8) << 16) >> 16;
    }
    return out;
  }
  return {id: clip.id, frames: clip.frames, fps: clip.fps, loop: !!clip.loop,
    data: decode(clip.rot, clip.frames * joints * 3),
    trans: decode(clip.trans, clip.frames * 3)};
}
