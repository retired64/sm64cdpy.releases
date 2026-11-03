import { GameParser, animationForRom } from "./player3d-index.js";
import { buildPlayerModel } from "./player3d-model.js";
import { readIdleClips, decodeClip } from "./player3d-clips.js";
import { marioPreview } from "./player3d-renderer.js";

const PARTS = ["pants", "shirt", "gloves", "shoes", "hair", "skin", "cap", "emblem"];
const CACHE_SCHEMA = "player3d-rig-v4-clips-v2";
const CACHE_DB = "sm64cdpy-player3d", CACHE_STORE = "renders";
let parser = null, parserTask = null, clips = null, preview = null;
let activeModel = -1, activeColors = [], generation = 0, disposed = false;
let cacheIdentity = null, database = null, stageVisible = true;
let pendingProfile = null, rendering = false, snapshotFrame = 0, snapshotTimer = 0;
const modelCache = new Map();
const stage = document.getElementById("stage");
const current = token => !disposed && token === generation;
const report = (state, detail = "") => {
  if (disposed) return;
  try { Player3DBridge.postState(JSON.stringify({state, detail})); } catch (_) {}
};
const colorMap = colors => Object.fromEntries(PARTS.map((part, index) =>
  [part, `#${Number(colors[index] ?? 0x808080).toString(16).padStart(6, "0").slice(-6)}`]));
const paletteKey = colors => colors.map(color => color.toString(16).padStart(6, "0")).join("");
const reducedMotion = () => window.matchMedia?.("(prefers-reduced-motion: reduce)").matches ?? false;
const visibility = "IntersectionObserver" in window ? new IntersectionObserver(([entry]) => {
  stageVisible = entry?.isIntersecting ?? true;
  preview?.setActive(stageVisible);
}, {threshold: 0.01}) : {observe() {}, disconnect() {}};
visibility.observe(stage);

async function binary(path) {
  const response = await fetch(path, {cache: "no-store"});
  if (!response.ok) throw new Error(`${path}: ${response.status}`);
  return new Uint8Array(await response.arrayBuffer());
}
async function identity() {
  if (!cacheIdentity) {
    cacheIdentity = (async () => {
      const response = await fetch("./source-key.txt", {cache: "no-store"});
      if (!response.ok) throw new Error(`source-key: ${response.status}`);
      const id = `${CACHE_SCHEMA}:${await response.text()}`;
      await pruneCache(id);
      return id;
    })();
  }
  return cacheIdentity;
}
function openCache() {
  if (!database) database = new Promise((resolve, reject) => {
    const request = indexedDB.open(CACHE_DB, 1);
    request.onupgradeneeded = () => request.result.createObjectStore(CACHE_STORE);
    request.onsuccess = () => resolve(request.result);
    request.onerror = () => reject(request.error);
  });
  return database;
}
async function cached(key) {
  try {
    const db = await openCache();
    return await new Promise((resolve, reject) => {
      const request = db.transaction(CACHE_STORE).objectStore(CACHE_STORE).get(key);
      request.onsuccess = () => resolve(request.result ?? null);
      request.onerror = () => reject(request.error);
    });
  } catch { return null; }
}
async function cache(key, value) {
  try {
    const db = await openCache();
    await new Promise((resolve, reject) => {
      const tx = db.transaction(CACHE_STORE, "readwrite");
      tx.objectStore(CACHE_STORE).put(value, key);
      tx.oncomplete = resolve;
      tx.onerror = tx.onabort = () => reject(tx.error);
    });
  } catch { /* Cache is optional, never authority. */ }
}
async function pruneCache(id) {
  try {
    const db = await openCache();
    await new Promise((resolve, reject) => {
      const tx = db.transaction(CACHE_STORE, "readwrite");
      const request = tx.objectStore(CACHE_STORE).openCursor();
      request.onsuccess = () => {
        const cursor = request.result;
        if (!cursor) return;
        if (!String(cursor.key).startsWith(`${id}:`)) cursor.delete();
        cursor.continue();
      };
      tx.oncomplete = resolve;
      tx.onerror = tx.onabort = () => reject(tx.error);
    });
  } catch { /* A denied/full cache must not block the viewer. */ }
}
async function showCachedFrame(model, colors, token) {
  const frame = await cached(`${await identity()}:frame:${model}`);
  if (!current(token) || !frame || frame.palette !== paletteKey(colors) ||
      !/^data:image\/webp[;,]/.test(frame.source)) return;
  const image = document.createElement("img");
  image.className = "cached-frame";
  image.alt = "";
  image.src = frame.source;
  stage.replaceChildren(image);
  report("preview");
}
function rememberFrame(model, colors, token) {
  clearTimeout(snapshotTimer);
  cancelAnimationFrame(snapshotFrame);
  // Palette blending lasts 280 ms. Cache only the finished palette, never an
  // intermediate frame tagged as if it already contained the new colours.
  snapshotTimer = setTimeout(() => {
    snapshotTimer = 0;
    snapshotFrame = requestAnimationFrame(async () => {
      snapshotFrame = 0;
      if (!current(token) || activeModel !== model) return;
      const canvas = stage.querySelector("canvas");
      if (!canvas) return;
      try {
        // Render explicitly before readback: the WebGL drawing buffer need not persist.
        preview?.renderOnce();
        const source = canvas.toDataURL("image/webp", 0.82);
        const id = await identity();
        if (current(token)) await cache(`${id}:frame:${model}`, {palette: paletteKey(colors), source});
      } catch { /* Snapshot failure has no effect on the live preview. */ }
    });
  }, 320);
}
async function ensureParser() {
  if (parser) return;
  if (!parserTask) parserTask = (async () => {
    const [game, rom] = await Promise.all([binary("./game.bin"), binary("./rom.bin")]);
    if (disposed) return;
    parser = new GameParser(game, rom);
  })().catch(error => { parserTask = null; throw error; });
  await parserTask;
}
function validModel(data, model) {
  const numbers = (value, length) => Array.isArray(value) && value.length === length &&
    value.every(Number.isFinite);
  if (data?.version !== 4 || data.character !== model || !Array.isArray(data.nodes) ||
      data.nodes.length < 2 || data.nodes.length > 65 || !Array.isArray(data.groups) ||
      data.groups.length < 1 || data.groups.length > 2048 || !Array.isArray(data.textures)) return false;
  const nodesValid = data.nodes.every((node, index) => Number.isInteger(node.parent) &&
    (index === 0 ? node.parent === -1 : node.parent >= 0 && node.parent < index) &&
    numbers(node.local, 16) && Number.isInteger(node.joint) && node.joint >= -1 && node.joint < 64);
  const jointCount = Math.max(...data.nodes.map(node => node.joint)) + 1;
  return nodesValid && numbers(data.pose, jointCount * 3) && data.groups.every(group => Number.isInteger(group.node) &&
    group.node >= 0 && group.node < data.nodes.length && Array.isArray(group.pos) &&
    group.pos.length > 0 && group.pos.length <= 3000000 && group.pos.length % 9 === 0 &&
    numbers(group.pos, group.pos.length) && numbers(group.nrm, group.pos.length) &&
    numbers(group.uv0, group.pos.length / 3 * 2) && numbers(group.uv1, group.pos.length / 3 * 2) &&
    numbers(group.tex, 2) && numbers(group.wrap, 4) && numbers(group.combine, 2) &&
    numbers(group.env, 4) && numbers(group.prim, 4)) &&
    data.textures.length <= 128 && data.textures.every(texture => Number.isFinite(texture.id) &&
      Number.isInteger(texture.w) && texture.w > 0 && texture.w <= 2048 &&
      Number.isInteger(texture.h) && texture.h > 0 && texture.h <= 2048 &&
      typeof texture.rgba === "string" && texture.rgba.length === Math.ceil(texture.w * texture.h * 4 / 3) * 4);
}

async function ensureClips(id) {
  if (clips) return clips;
  let value = await cached(`${id}:clips`);
  try {
    if (value?.version !== 2 || value.joints !== 20 || value.clips?.length !== 3 ||
        !Array.isArray(value.sequence) || value.sequence.join(",") !== "idle-left,idle-right,idle-center" ||
        value.clips.some((clip, index) => clip.id !== value.sequence[index])) throw Error();
    value.clips.forEach(clip => decodeClip(clip, value.joints));
  } catch { value = null; }
  if (!value) {
    await ensureParser();
    if (disposed) return null;
    try {
      value = readIdleClips(parser.rom);
      await cache(`${id}:clips`, value);
    } catch { return null; } // Keep the reference pose when optional animation is unavailable.
  }
  clips = value;
  return clips;
}
async function render(model, colors, token) {
  if (!preview) await showCachedFrame(model, colors, token);
  if (!current(token)) return;
  if (model === activeModel && preview) {
    activeColors = [...colors];
    preview.setColors(colorMap(colors));
    report("ready");
    rememberFrame(model, colors, token);
    return;
  }
  const id = await identity();
  if (!current(token)) return;
  let data = modelCache.get(model) ?? await cached(`${id}:model:${model}`);
  if (!current(token)) return;
  if (!validModel(data, model)) {
    await ensureParser();
    if (!current(token)) return;
    data = buildPlayerModel(parser, model, animationForRom(parser.rom));
    if (!validModel(data, model)) throw new Error("model_empty");
    await cache(`${id}:model:${model}`, data);
  }
  if (!current(token)) return;
  modelCache.set(model, data);
  if (modelCache.size > 2) modelCache.delete(modelCache.keys().next().value);
  const idle = await ensureClips(id);
  if (!current(token)) return;
  preview?.dispose();
  preview = null;
  let next;
  next = marioPreview(data, colorMap(colors), {
    clips: idle, reducedMotion,
    onError: error => {
      if (!disposed && preview === next) {
        preview = null;
        activeModel = -1;
        next.dispose();
        report("error", error?.message || "webgl_lost");
      }
    },
  });
  preview = next;
  next.setActive(stageVisible);
  stage.replaceChildren(next.el);
  activeModel = model;
  activeColors = [...colors];
  report("ready");
  rememberFrame(model, colors, token);
}
// Coalesce updates while reading local files/cache. Only one extraction is active;
// every awaited boundary rejects obsolete profiles, including palette-only updates.
async function drain() {
  if (rendering || disposed) return;
  rendering = true;
  try {
    while (pendingProfile && !disposed) {
      const {model, colors, token} = pendingProfile;
      pendingProfile = null;
      try { await render(model, colors, token); }
      catch (error) { if (current(token)) report("error", error?.message || "render_failed"); }
    }
  } finally { rendering = false; }
}
window.player3dUpdate = payload => {
  if (disposed) return Promise.resolve();
  try {
    const value = typeof payload === "string" ? JSON.parse(payload) : payload;
    const model = Math.max(0, Math.min(4, Math.trunc(Number(value.model) || 0)));
    const colors = Array.isArray(value.colors) && value.colors.length === 8 ?
      value.colors.map(color => Number(color) & 0xffffff) : [...activeColors];
    pendingProfile = {model, colors, token: ++generation};
    return drain(); // Catches per-profile failures internally; native need not await.
  } catch (error) { report("error", error?.message || "profile_invalid"); return Promise.resolve(); }
};
window.addEventListener("pagehide", () => {
  disposed = true;
  generation++;
  pendingProfile = null;
  clearTimeout(snapshotTimer);
  cancelAnimationFrame(snapshotFrame);
  visibility.disconnect();
  preview?.dispose();
  preview = null;
  parser = null;
  modelCache.clear();
  // openCache may still be pending. Capture rejection for this intentional cleanup.
  if (database) void database.then(db => db.close()).catch(() => {});
}, {once: true});
report("bridge-ready");
