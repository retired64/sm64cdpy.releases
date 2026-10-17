import {
  GameParser,
  animationForRom,
  buildPlayerModel,
} from "./player3d-index.js";
import { marioPreview } from "./player3d-renderer.js";

const PARTS = [
  "pants", "shirt", "gloves", "shoes",
  "hair", "skin", "cap", "emblem",
];

const CACHE_SCHEMA = "player3d-v2";
const CACHE_DB = "sm64cdpy-player3d";
const CACHE_STORE = "renders";

let parser = null;
let preview = null;
let activeModel = -1;
let activeColors = [];
let generation = 0;
const modelCache = new Map();
let stageVisible = true;
const stage = document.getElementById("stage");
let cacheIdentity = null;
let database = null;
const visibility = "IntersectionObserver" in window
  ? new IntersectionObserver(([entry]) => {
      stageVisible = entry?.isIntersecting ?? true;
      preview?.setActive(stageVisible);
    }, { threshold: 0.01 })
  : { observe() {}, disconnect() {} };
visibility.observe(stage);

const report = (state, detail = "") => {
  try {
    Player3DBridge.postState(JSON.stringify({ state, detail }));
  } catch (_) {}
};

const colorMap = (colors) => Object.fromEntries(
  PARTS.map((part, index) => [
    part,
    `#${Number(colors[index] ?? 0x808080).toString(16).padStart(6, "0").slice(-6)}`,
  ]),
);

async function binary(path) {
  const response = await fetch(path, { cache: "no-store" });
  if (!response.ok) throw new Error(`${path}: ${response.status}`);
  return new Uint8Array(await response.arrayBuffer());
}

async function identity() {
  if (cacheIdentity) return cacheIdentity;
  const response = await fetch("./source-key.txt", { cache: "no-store" });
  if (!response.ok) throw new Error(`source-key: ${response.status}`);
  cacheIdentity = `${CACHE_SCHEMA}:${await response.text()}`;
  void pruneCache(cacheIdentity);
  return cacheIdentity;
}

function openCache() {
  if (database) return database;
  database = new Promise((resolve, reject) => {
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
  } catch (_) {
    return null;
  }
}

async function cache(key, value) {
  try {
    const db = await openCache();
    await new Promise((resolve, reject) => {
      const request = db.transaction(CACHE_STORE, "readwrite").objectStore(CACHE_STORE).put(value, key);
      request.onsuccess = () => resolve();
      request.onerror = () => reject(request.error);
    });
  } catch (_) {}
}

async function pruneCache(activeIdentity) {
  try {
    const db = await openCache();
    await new Promise((resolve, reject) => {
      const transaction = db.transaction(CACHE_STORE, "readwrite");
      const store = transaction.objectStore(CACHE_STORE);
      const request = store.openCursor();
      request.onsuccess = () => {
        const cursor = request.result;
        if (!cursor) return;
        if (!String(cursor.key).startsWith(`${activeIdentity}:`)) cursor.delete();
        cursor.continue();
      };
      transaction.oncomplete = () => resolve();
      transaction.onerror = () => reject(transaction.error);
    });
  } catch (_) {}
}

const paletteKey = (colors) => colors.map((color) => Number(color).toString(16).padStart(6, "0")).join("");

async function showCachedFrame(model, colors) {
  const key = `${await identity()}:frame:${model}`;
  const frame = await cached(key);
  if (!frame || frame.palette !== paletteKey(colors) || !frame.source) return;
  const image = document.createElement("img");
  image.className = "cached-frame";
  image.alt = "Your cached character preview";
  image.src = frame.source;
  stage.replaceChildren(image);
  report("preview");
}

function rememberFrame(model, colors) {
  requestAnimationFrame(() => {
    const canvas = stage.querySelector("canvas");
    if (!canvas) return;
    try {
      const source = canvas.toDataURL("image/webp", 0.82);
      void identity().then((id) => cache(`${id}:frame:${model}`, {
        palette: paletteKey(colors),
        source,
      }));
    } catch (_) {}
  });
}

async function ensureParser() {
  if (parser) return;
  report("loading");
  const [game, rom] = await Promise.all([binary("./game.bin"), binary("./rom.bin")]);
  parser = new GameParser(game, rom);
}

async function render(model, colors) {
  const request = ++generation;
  let data = modelCache.get(model);
  if (!data) {
    const key = `${await identity()}:model:${model}`;
    data = await cached(key);
    if (!data) {
      await ensureParser();
      if (request !== generation) return;
      // animationForRom is a consumable pose reader. Reusing it shifts every
      // subsequent model's joints and visibly folds the character into itself.
      data = buildPlayerModel(parser, model, animationForRom(parser.rom));
      if (data?.groups?.length) void cache(key, data);
    }
    if (data?.groups?.length) {
      modelCache.set(model, data);
      if (modelCache.size > 2) modelCache.delete(modelCache.keys().next().value);
    }
  }
  if (!data?.groups?.length) throw new Error("model_empty");
  if (request !== generation) return;
  preview?.dispose();
  preview = marioPreview(data, colorMap(colors));
  preview.setActive(stageVisible);
  stage.replaceChildren(preview.el);
  activeModel = model;
  activeColors = [...colors];
  report("ready");
  rememberFrame(model, colors);
}

window.player3dUpdate = async (payload) => {
  try {
    const value = typeof payload === "string" ? JSON.parse(payload) : payload;
    const model = Math.max(0, Math.min(4, Number(value.model) || 0));
    const colors = Array.isArray(value.colors) && value.colors.length === 8
      ? value.colors.map((color) => Number(color) & 0xffffff)
      : activeColors;
    if (!preview) await showCachedFrame(model, colors);
    if (model === activeModel && preview) {
      activeColors = [...colors];
      preview.setColors(colorMap(colors));
      report("ready");
      return;
    }
    await render(model, colors);
  } catch (error) {
    report("error", error?.message || "render_failed");
  }
};

window.addEventListener("pagehide", () => {
  visibility.disconnect();
  preview?.dispose();
}, { once: true });
report("bridge-ready");
