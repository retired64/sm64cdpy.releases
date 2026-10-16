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

let parser = null;
let preview = null;
let activeModel = -1;
let activeColors = [];
let generation = 0;
const modelCache = new Map();
let stageVisible = true;
const stage = document.getElementById("stage");
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

async function ensureParser() {
  if (parser) return;
  report("loading");
  const [game, rom] = await Promise.all([binary("./game.bin"), binary("./rom.bin")]);
  parser = new GameParser(game, rom);
}

async function render(model, colors) {
  const request = ++generation;
  await ensureParser();
  if (request !== generation) return;
  // animationForRom is a consumable pose reader. Reusing it shifts every
  // subsequent model's joints and visibly folds the character into itself.
  let data = modelCache.get(model);
  if (!data) {
    data = buildPlayerModel(parser, model, animationForRom(parser.rom));
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
}

window.player3dUpdate = async (payload) => {
  try {
    const value = typeof payload === "string" ? JSON.parse(payload) : payload;
    const model = Math.max(0, Math.min(4, Number(value.model) || 0));
    const colors = Array.isArray(value.colors) && value.colors.length === 8
      ? value.colors.map((color) => Number(color) & 0xffffff)
      : activeColors;
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
