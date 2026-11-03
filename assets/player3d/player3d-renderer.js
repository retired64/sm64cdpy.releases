// The Player tab's 3D preview.
//
// The geometry, textures and combiner parameters come from the player's own
// game files through /api/player/model. Three.js draws them with the same
// N64-style combiner and the same 28° camera the reference client uses.
// No model or texture is stored in this repository.
//
// The model arrives as a small transform tree: every animated part is a node
// whose local translation is fixed and whose rotation comes from the idle
// clips. The game plays three NOLOOP clips in a row (head left, head right,
// head centre), so the viewer chains them instead of looping one of them.
import * as THREE from "./vendor/three.module.js";
import { decodeClip } from "./player3d-clips.js";

const PART_COLORS = {
  pants: "#0000ff",
  shirt: "#ff0000",
  gloves: "#ffffff",
  shoes: "#8b4513",
  hair: "#5a3214",
  skin: "#ffc0a0",
  cap: "#ff0000",
  emblem: "#ff0000",
};

const WRAP = [
  THREE.RepeatWrapping,
  THREE.MirroredRepeatWrapping,
  THREE.ClampToEdgeWrapping,
  THREE.ClampToEdgeWrapping,
];

// Length of the blend between two idle clips, in seconds. The measured seams
// are only a few degrees wide, so 100 ms hides them without a visible pause.
const CROSSFADE = 0.1;
const TAU = Math.PI * 2;

const VERTEX_SHADER = `
  attribute vec2 uv1;
  uniform vec3 uDiff;
  uniform vec3 uAmb;
  varying vec3 vShade;
  varying vec2 vUv0;
  varying vec2 vUv1;

  void main() {
    vec3 n = normalize(normalMatrix * normal);
    vec3 L = normalize(vec3(1.0, 1.0, 1.0));
    vShade = min(uAmb + uDiff * 0.8 * max(dot(n, L), 0.0), vec3(1.0));
    vUv0 = uv;
    vUv1 = uv1;
    gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
  }
`;

const FRAGMENT_SHADER = `
  uniform sampler2D uT0;
  uniform sampler2D uT1;
  uniform vec4 uEnv;
  uniform vec4 uPrim;
  uniform vec4 uC0;
  uniform vec4 uA0;
  uniform vec4 uC1;
  uniform vec4 uA1;
  uniform float uTwo;

  varying vec3 vShade;
  varying vec2 vUv0;
  varying vec2 vUv1;

  vec4 T0;
  vec4 T1;
  vec4 SH;
  vec3 CMB;
  float CMBA;

  vec3 cA(int s) {
    if (s == 0) return CMB;
    if (s == 1) return T0.rgb;
    if (s == 2) return T1.rgb;
    if (s == 3) return uPrim.rgb;
    if (s == 4) return SH.rgb;
    if (s == 5) return uEnv.rgb;
    if (s == 6) return vec3(1.0);
    return vec3(0.0);
  }
  vec3 cB(int s) {
    if (s == 0) return CMB;
    if (s == 1) return T0.rgb;
    if (s == 2) return T1.rgb;
    if (s == 3) return uPrim.rgb;
    if (s == 4) return SH.rgb;
    if (s == 5) return uEnv.rgb;
    return vec3(0.0);
  }
  vec3 cC(int s) {
    if (s == 0) return CMB;
    if (s == 1) return T0.rgb;
    if (s == 2) return T1.rgb;
    if (s == 3) return uPrim.rgb;
    if (s == 4) return SH.rgb;
    if (s == 5) return uEnv.rgb;
    if (s == 7) return vec3(CMBA);
    if (s == 8) return vec3(T0.a);
    if (s == 9) return vec3(T1.a);
    if (s == 10) return vec3(uPrim.a);
    if (s == 11) return vec3(SH.a);
    if (s == 12) return vec3(uEnv.a);
    return vec3(0.0);
  }
  vec3 cD(int s) {
    if (s == 0) return CMB;
    if (s == 1) return T0.rgb;
    if (s == 2) return T1.rgb;
    if (s == 3) return uPrim.rgb;
    if (s == 4) return SH.rgb;
    if (s == 5) return uEnv.rgb;
    if (s == 6) return vec3(1.0);
    return vec3(0.0);
  }
  float aABD(int s) {
    if (s == 0) return CMBA;
    if (s == 1) return T0.a;
    if (s == 2) return T1.a;
    if (s == 3) return uPrim.a;
    if (s == 4) return SH.a;
    if (s == 5) return uEnv.a;
    if (s == 6) return 1.0;
    return 0.0;
  }
  float aC(int s) {
    if (s == 1) return T0.a;
    if (s == 2) return T1.a;
    if (s == 3) return uPrim.a;
    if (s == 4) return SH.a;
    if (s == 5) return uEnv.a;
    return 0.0;
  }
  void cycle(vec4 c, vec4 a) {
    ivec4 ci = ivec4(c + 0.5);
    ivec4 ai = ivec4(a + 0.5);
    vec3 rgb = clamp((cA(ci.x) - cB(ci.y)) * cC(ci.z) + cD(ci.w), 0.0, 1.0);
    float al = clamp((aABD(ai.x) - aABD(ai.y)) * aC(ai.z) + aABD(ai.w), 0.0, 1.0);
    CMB = rgb;
    CMBA = al;
  }
  void main() {
    SH = vec4(vShade, 1.0);
    T0 = texture2D(uT0, vUv0);
    T1 = texture2D(uT1, vUv1);
    CMB = vec3(0.0);
    CMBA = 0.0;
    cycle(uC0, uA0);
    if (uTwo > 0.5) {
      vec4 t = T0;
      T0 = T1;
      T1 = t;
      cycle(uC1, uA1);
    }
    if (CMBA < 0.01) discard;
    // Matched by eye against the game, like the reference client.
    gl_FragColor = vec4(pow(CMB, vec3(1.1)), CMBA);
  }
`;

function b64bytes(text) {
  const raw = atob(text || "");
  const out = new Uint8Array(raw.length);
  for (let i = 0; i < raw.length; i++) out[i] = raw.charCodeAt(i);
  return out;
}

function splitCombiner(word0, word1) {
  const w0 = word0 >>> 0;
  const w1 = word1 >>> 0;
  return [
    new THREE.Vector4((w0 >>> 20) & 15, (w1 >>> 28) & 15, (w0 >>> 15) & 31, (w1 >>> 15) & 7),
    new THREE.Vector4((w0 >>> 12) & 7, (w1 >>> 12) & 7, (w0 >>> 9) & 7, (w1 >>> 9) & 7),
    new THREE.Vector4((w0 >>> 5) & 15, (w1 >>> 24) & 15, w0 & 31, (w1 >>> 6) & 7),
    new THREE.Vector4((w1 >>> 21) & 7, (w1 >>> 3) & 7, (w1 >>> 18) & 7, w1 & 7),
  ];
}

function colorFor(source, colors) {
  const rgb = source && source.rgb;
  if (rgb) return new THREE.Color(rgb[0] / 255, rgb[1] / 255, rgb[2] / 255);
  const part = source && source.part ? source.part : "skin";
  const value = colors[part] || PART_COLORS[part] || "#808080";
  return new THREE.Color(value).multiplyScalar(source && typeof source.k === "number" ? source.k : 1);
}

function sourceKey(source) {
  if (!source) return "";
  if (source.rgb) return "rgb:" + source.rgb.join(",");
  return "part:" + source.part + ":" + source.k;
}

// Same rotation order and units as the game's mtxf_rotate_xyz_and_translate,
// so the rig matches the pose the extractor already validated.
function angleMatrix(ax, ay, az, out) {
  const rx = (ax / 65536) * TAU;
  const ry = (ay / 65536) * TAU;
  const rz = (az / 65536) * TAU;
  const i = Math.sin(rx);
  const o = Math.cos(rx);
  const a = Math.sin(ry);
  const c = Math.cos(ry);
  const l = Math.sin(rz);
  const u = Math.cos(rz);
  out[0] = c * u;
  out[1] = c * l;
  out[2] = -a;
  out[3] = 0;
  out[4] = i * a * u - o * l;
  out[5] = i * a * l + o * u;
  out[6] = i * c;
  out[7] = 0;
  out[8] = o * a * u + i * l;
  out[9] = o * a * l - i * u;
  out[10] = o * c;
  out[11] = 0;
  out[12] = 0;
  out[13] = 0;
  out[14] = 0;
  out[15] = 1;
}

// Pure scene-graph animation, shared by the WebGL viewer and CPU regressions.
// No canvas/GPU is needed to verify interpolation, root translation or seams.
export function createIdleMotion(model, animated, baseMatrices, jointCount, clipSet, prefersReduced) {
  // A bad optional clip must not hide an otherwise valid character.
  let clips = [];
  if (clipSet?.joints === jointCount) {
    try { clips = clipSet.clips.map(clip => decodeClip(clip, jointCount)); }
    catch { clips = []; }
  }
  const sequence = Array.isArray(clipSet?.sequence) ? clipSet.sequence : [];
  const ordered = sequence
    .map((id) => clips.find((clip) => clip.id === id))
    .filter(Boolean);
  if (ordered.length !== clips.length) {
    for (const clip of clips) {
      if (!ordered.includes(clip)) ordered.push(clip);
    }
  }

  const angleArray = new Float64Array(16);
  const baseQuat = Array.from({ length: Math.max(jointCount, 1) }, () => new THREE.Quaternion());
  const nextQuat = Array.from({ length: Math.max(jointCount, 1) }, () => new THREE.Quaternion());
  const previousQuat = Array.from({ length: Math.max(jointCount, 1) }, () => new THREE.Quaternion());
  const currentQuat = Array.from({ length: Math.max(jointCount, 1) }, () => new THREE.Quaternion());
  const scratchMatrix = new THREE.Matrix4();
  const rotationMatrix = new THREE.Matrix4();
  const translationMatrix = new THREE.Matrix4();
  const poseMatrix = new THREE.Matrix4();
  const zeroTrans = new THREE.Vector3();
  const currentTrans = new THREE.Vector3();
  const previousTrans = new THREE.Vector3();
  const blendedTrans = new THREE.Vector3();

  function anglesToQuat(ax, ay, az, target) {
    angleMatrix(ax, ay, az, angleArray);
    scratchMatrix.fromArray(angleArray);
    return target.setFromRotationMatrix(scratchMatrix);
  }

  function applyPose(quats, trans) {
    for (const entry of animated) {
      if (entry.joint >= quats.length) continue;
      rotationMatrix.makeRotationFromQuaternion(quats[entry.joint]);
      if (entry.joint === 0 && trans && (trans.x || trans.y || trans.z)) {
        // The game's first animated part carries a translation as well as a
        // rotation. It is the body bob that keeps the feet on the ground
        // while the legs flex; dropping it makes the character hop.
        translationMatrix.makeTranslation(trans.x, trans.y, trans.z);
        poseMatrix.multiplyMatrices(translationMatrix, rotationMatrix);
        entry.object.matrix.copy(baseMatrices[entry.node]).multiply(poseMatrix);
      } else {
        entry.object.matrix.copy(baseMatrices[entry.node]).multiply(rotationMatrix);
      }
    }
  }

  function referencePose() {
    const pose = model.pose;
    if (!Array.isArray(pose)) return false;
    for (const entry of animated) {
      const at = entry.joint * 3;
      if (at + 2 >= pose.length) continue;
      baseQuat[entry.joint] = anglesToQuat(pose[at], pose[at + 1], pose[at + 2], baseQuat[entry.joint]);
    }
    applyPose(baseQuat, zeroTrans);
    return true;
  }

  function initialPose() {
    // Reduced motion shows the first frame of the first idle clip, which is
    // the neutral standing pose. Without clips, keep the reference pose.
    if (ordered.length) {
      sampleClip(ordered[0], 0, baseQuat, currentTrans);
      applyPose(baseQuat, currentTrans);
    } else {
      referencePose();
    }
  }

  function sampleClip(clip, time, out, transOut) {
    const per = jointCount * 3;
    const maxFrame = clip.frames - 1;
    let t = time * clip.fps;
    if (!Number.isFinite(t) || t < 0) t = 0;
    if (t > maxFrame) t = maxFrame;
    const f0 = Math.floor(t);
    const f1 = Math.min(f0 + 1, maxFrame);
    const frac = t - f0;
    for (let j = 0; j < jointCount; j++) {
      const a = f0 * per + j * 3;
      anglesToQuat(clip.data[a], clip.data[a + 1], clip.data[a + 2], currentQuat[j]);
      if (frac > 0 && f1 !== f0) {
        const b = f1 * per + j * 3;
        anglesToQuat(clip.data[b], clip.data[b + 1], clip.data[b + 2], nextQuat[j]);
        currentQuat[j].slerp(nextQuat[j], frac);
      }
    }
    for (let j = 0; j < jointCount; j++) out[j].copy(currentQuat[j]);
    if (transOut) {
      const a = f0 * 3;
      const b = f1 * 3;
      if (clip.trans && clip.trans.length >= b + 3) {
        transOut.set(
          clip.trans[a] + (clip.trans[b] - clip.trans[a]) * frac,
          clip.trans[a + 1] + (clip.trans[b + 1] - clip.trans[a + 1]) * frac,
          clip.trans[a + 2] + (clip.trans[b + 2] - clip.trans[a + 2]) * frac,
        );
      } else {
        transOut.set(0, 0, 0);
      }
    }
  }

  let motionOn = !prefersReduced;
  let clipIndex = 0;
  let clipTime = 0;
  let fadeLeft = 0;

  function clipDuration(clip) {
    return clip.frames / clip.fps;
  }

  function applyIdle(delta) {
    if (!ordered.length) return;
    clipTime += delta;
    let guard = 0;
    while (clipTime >= clipDuration(ordered[clipIndex]) && guard++ < 8) {
      clipTime -= clipDuration(ordered[clipIndex]);
      // Freeze the outgoing pose for the length of the blend; the new clip
      // keeps advancing, so the head never pauses.
      sampleClip(ordered[clipIndex], clipDuration(ordered[clipIndex]), previousQuat, previousTrans);
      clipIndex = (clipIndex + 1) % ordered.length;
      fadeLeft = CROSSFADE;
    }
    sampleClip(ordered[clipIndex], clipTime, currentQuat, currentTrans);
    if (fadeLeft > 0) {
      const w = 1 - fadeLeft / CROSSFADE;
      for (let j = 0; j < jointCount; j++) {
        baseQuat[j].copy(previousQuat[j]).slerp(currentQuat[j], w);
      }
      blendedTrans.copy(previousTrans).lerp(currentTrans, w);
      applyPose(baseQuat, blendedTrans);
      fadeLeft = Math.max(0, fadeLeft - delta);
    } else {
      applyPose(currentQuat, currentTrans);
    }
  }

  if (!ordered.length) motionOn = false;

  return {
    initialPose,
    advance(delta) { if (motionOn && Number.isFinite(delta)) applyIdle(Math.min(Math.max(delta, 0), 0.1)); },
    play() { motionOn = ordered.length > 0; },
    get playing() { return motionOn; },
    get hasClips() { return ordered.length > 0; },
  };
}

export function marioPreview(model, colors, options = {}) {
  if (!model || !Array.isArray(model.groups) || !model.groups.length) {
    throw new Error("model_empty");
  }
  const prefersReduced = !!(options.reducedMotion && options.reducedMotion());
  const onError = typeof options.onError === "function" ? options.onError : () => {};

  const canvas = document.createElement("canvas");
  canvas.className = "mario-canvas";
  canvas.tabIndex = -1;
  canvas.setAttribute("role", "img");
  canvas.setAttribute("aria-hidden", "true");
  const stage = document.createElement("div");
  stage.className = "mario-stage";
  stage.append(canvas);
  const el = document.createElement("div");
  el.className = "mario-box";
  el.append(stage);
  el.style.width = "100%"; el.style.height = "100%";

  let renderer;
  try {
    renderer = new THREE.WebGLRenderer({ canvas, antialias: true, alpha: true });
  } catch (err) {
    onError(err);
    throw err;
  }
  renderer.sortObjects = false;
  renderer.setClearColor(0x000000, 0);
  renderer.outputColorSpace = THREE.SRGBColorSpace;

  const scene = new THREE.Scene();
  const camera = new THREE.PerspectiveCamera(28, 1, 1, 5000);
  const root = new THREE.Group();
  const pivot = new THREE.Group();
  root.add(pivot);
  scene.add(root);

  // Textures are shared between groups that use the same image and wrapping.
  const textureByID = new Map();
  const white = new THREE.DataTexture(new Uint8Array([255, 255, 255, 255]), 1, 1, THREE.RGBAFormat);
  white.magFilter = THREE.NearestFilter;
  white.minFilter = THREE.NearestFilter;
  white.needsUpdate = true;

  for (const tex of model.textures || []) {
    textureByID.set(tex.id, {
      w: tex.w,
      h: tex.h,
      data: b64bytes(tex.rgba),
    });
  }

  function textureFor(id, wrapS, wrapT) {
    if (!id) return white;
    const info = textureByID.get(id);
    if (!info) return white;
    const key = id + "|" + wrapS + "|" + wrapT;
    let cached = textureFor.cache.get(key);
    if (cached) return cached;
    const texture = new THREE.DataTexture(info.data, info.w, info.h, THREE.RGBAFormat);
    texture.magFilter = THREE.NearestFilter;
    texture.minFilter = THREE.NearestFilter;
    texture.generateMipmaps = false;
    texture.flipY = false;
    texture.wrapS = WRAP[wrapS] ?? THREE.ClampToEdgeWrapping;
    texture.wrapT = WRAP[wrapT] ?? THREE.ClampToEdgeWrapping;
    texture.needsUpdate = true;
    textureFor.cache.set(key, texture);
    return texture;
  }
  textureFor.cache = new Map();

  // ---------------------------------------------------------------------
  // Rig: one Object3D per node, meshes in the node's own space.

  const nodes = Array.isArray(model.nodes) && model.nodes.length
    ? model.nodes
    : [{ parent: -1, local: [1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1], joint: -1 }];

  const nodeObjects = [];
  const baseMatrices = [];
  const animated = [];
  let jointCount = 0;
  nodes.forEach((node, index) => {
    const object = new THREE.Object3D();
    object.matrixAutoUpdate = false;
    object.matrix.fromArray(node.local || [1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1]);
    nodeObjects.push(object);
    baseMatrices.push(object.matrix.clone());
    if (typeof node.joint === "number" && node.joint >= 0) {
      animated.push({ object, node: index, joint: node.joint });
      jointCount = Math.max(jointCount, node.joint + 1);
    }
  });
  nodes.forEach((node, index) => {
    const parent = index === 0 ? -1 : node.parent;
    if (parent >= 0 && parent < nodeObjects.length) nodeObjects[parent].add(nodeObjects[index]);
    else pivot.add(nodeObjects[index]);
  });

  const materials = [];
  const geometries = [];

  model.groups.forEach((group, index) => {
    const geometry = new THREE.BufferGeometry();
    geometry.setAttribute("position", new THREE.Float32BufferAttribute(group.pos, 3));
    geometry.setAttribute("normal", new THREE.Float32BufferAttribute(group.nrm, 3));
    geometry.setAttribute("uv", new THREE.Float32BufferAttribute(group.uv0, 2));
    geometry.setAttribute("uv1", new THREE.Float32BufferAttribute(group.uv1, 2));
    geometry.computeBoundingBox();
    geometry.computeBoundingSphere();

    const [c0, a0, c1, a1] = splitCombiner(group.combine[0], group.combine[1]);
    const material = new THREE.ShaderMaterial({
      vertexShader: VERTEX_SHADER,
      fragmentShader: FRAGMENT_SHADER,
      transparent: true,
      depthFunc: THREE.LessEqualDepth,
      uniforms: {
        uT0: { value: textureFor(group.tex[0], group.wrap[0], group.wrap[1]) },
        uT1: { value: textureFor(group.tex[1], group.wrap[2], group.wrap[3]) },
        uDiff: { value: colorFor(group.diffuse, colors) },
        uAmb: { value: colorFor(group.ambient, colors) },
        uEnv: { value: new THREE.Vector4(group.env[0] / 255, group.env[1] / 255, group.env[2] / 255, group.env[3] / 255) },
        uPrim: { value: new THREE.Vector4(group.prim[0] / 255, group.prim[1] / 255, group.prim[2] / 255, group.prim[3] / 255) },
        uC0: { value: c0 },
        uA0: { value: a0 },
        uC1: { value: c1 },
        uA1: { value: a1 },
        uTwo: { value: group.cycle2 && group.tex[1] ? 1 : 0 },
      },
    });
    const mesh = new THREE.Mesh(geometry, material);
    mesh.renderOrder = index;
    mesh.frustumCulled = false;
    const owner = nodeObjects[group.node || 0] || nodeObjects[0];
    owner.add(mesh);

    materials.push({
      material,
      diffuse: group.diffuse,
      ambient: group.ambient,
      diffuseKey: sourceKey(group.diffuse),
      ambientKey: sourceKey(group.ambient),
    });
    geometries.push(geometry);
  });

  // ---------------------------------------------------------------------
  // Animation: the game's three-clip idle cycle.

  const motion = createIdleMotion(model, animated, baseMatrices, jointCount,
    options.clips, prefersReduced);

  // Apply the first idle frame (including the root translation that keeps the
  // feet on the ground) and centre on it, so the framing does not jump when
  // the clip starts.
  motion.initialPose();
  pivot.updateMatrixWorld(true);
  const box = new THREE.Box3().setFromObject(pivot);
  const center = box.getCenter(new THREE.Vector3());
  const size = box.getSize(new THREE.Vector3());
  pivot.position.set(-center.x, -center.y, -center.z);
  const height = Math.max(1, size.y);
  const distance = (height / 2) / Math.tan((camera.fov * Math.PI) / 360) * 1.15;
  camera.position.set(0, height * 0.04, distance);
  camera.lookAt(0, 0, 0);

  let angle = -0.5;
  let velocity = 0;
  let dragging = false;
  let pointerID = null;
  let lastX = 0;
  let lastMove = 0;
  let enabled = true;
  let visible = true;
  let disposed = false;
  let raf = 0;
  let lastFrame = 0;
  let colorAnimation = 0;

  function play() {
    if (!motion.hasClips) return;
    motion.play();
    start();
  }

  const gl = renderer.getContext();
  const renderScale = gl.getParameter(gl.MAX_TEXTURE_SIZE) <= 4096 ? 0.7 : 1;
  function resize() {
    const width = canvas.clientWidth || stage.clientWidth;
    const heightPx = canvas.clientHeight || stage.clientHeight;
    if (!width || !heightPx) return;
    // Preserve the mobile viewer's conservative rendering budget.
    const dpr = Math.min(window.devicePixelRatio || 1, 1.5);
    const scale = renderScale;
    if (canvas.width !== Math.round(width * dpr * scale) || canvas.height !== Math.round(heightPx * dpr * scale)) {
      renderer.setPixelRatio(dpr * scale);
      renderer.setSize(width, heightPx, false);
      camera.aspect = width / heightPx;
      camera.updateProjectionMatrix();
    }
  }

  function frame(now) {
    raf = 0;
    if (!enabled || !visible || document.hidden) return;
    if (!el.isConnected) {
      raf = requestAnimationFrame(frame);
      return;
    }
    // Advance at most 30 render frames/s; clip time remains wall-clock based.
    if (lastFrame && now - lastFrame < 1000 / 30 - 1) {
      raf = requestAnimationFrame(frame);
      return;
    }
    resize();
    const delta = lastFrame ? Math.min((now - lastFrame) / 1000, 0.1) : 0;
    lastFrame = now;

    if (!dragging) {
      if (Math.abs(velocity) > 0.0001) {
        angle += velocity * delta;
        velocity *= Math.exp(-4 * delta);
      } else {
        velocity = 0;
      }
    }
    root.rotation.y = angle;
    motion.advance(delta);
    renderer.render(scene, camera);
    raf = requestAnimationFrame(frame);
  }

  function start() {
    if (!raf) raf = requestAnimationFrame(frame);
  }
  function stop() {
    if (raf) cancelAnimationFrame(raf);
    raf = 0;
    lastFrame = 0;
  }

  function syncActive() {
    if (enabled && visible && !document.hidden) start();
    else stop();
  }
  function setActive(on) {
    enabled = !!on;
    syncActive();
  }

  // Pointer drag with inertia, like the reference client.
  canvas.addEventListener("pointerdown", (event) => {
    if (event.button !== undefined && event.button !== 0) return;
    dragging = true;
    pointerID = event.pointerId;
    lastX = event.clientX;
    lastMove = performance.now();
    velocity = 0;
    try { canvas.setPointerCapture?.(event.pointerId); } catch { /* no capture */ }
    event.preventDefault();
  });
  canvas.addEventListener("pointermove", (event) => {
    if (!dragging || event.pointerId !== pointerID) return;
    const now = performance.now();
    const dx = (event.clientX - lastX) * 0.01;
    const dt = Math.max(1, now - lastMove) / 1000;
    velocity = velocity * 0.6 + (dx / dt) * 0.4;
    angle += dx;
    lastX = event.clientX;
    lastMove = now;
    event.preventDefault();
  });
  function endDrag(event) {
    if (!dragging) return;
    if (pointerID !== null) {
      try { canvas.releasePointerCapture?.(pointerID); } catch { /* already released */ }
    }
    dragging = false;
    pointerID = null;
    if (performance.now() - lastMove > 80) velocity = 0;
    if (event) event.preventDefault();
  }
  canvas.addEventListener("pointerup", endDrag);
  canvas.addEventListener("pointercancel", endDrag);
  canvas.addEventListener("lostpointercapture", () => endDrag(null));
  canvas.addEventListener("keydown", (event) => {
    if (event.key === "ArrowLeft" || event.key === "ArrowRight") {
      angle += event.key === "ArrowLeft" ? -0.16 : 0.16;
      event.preventDefault();
    } else if (event.key === "Home") {
      angle = 0;
      velocity = 0;
      event.preventDefault();
    }
  });

  // Pause when the preview is not on screen or the tab is hidden.
  const observer = "IntersectionObserver" in window
    ? new IntersectionObserver(([entry]) => {
        visible = !!entry?.isIntersecting;
        syncActive();
      }, { threshold: 0.01 })
    : { observe() {}, disconnect() {} };
  observer.observe(el);
  const visibility = () => syncActive();
  document.addEventListener("visibilitychange", visibility);
  const resizeObserver = "ResizeObserver" in window
    ? new ResizeObserver(() => { resize(); if (enabled && visible && !document.hidden) start(); })
    : { observe() {}, disconnect() {} };
  resizeObserver.observe(canvas);
  window.addEventListener("resize", resize);

  function applyColors(colors, animate) {
    const targets = materials.map((item) => ({
      item,
      diffuse: colorFor(item.diffuse, colors),
      ambient: colorFor(item.ambient, colors),
    }));
    if (!animate || (prefersReduced && !motion.playing)) {
      for (const target of targets) {
        target.item.material.uniforms.uDiff.value.copy(target.diffuse);
        target.item.material.uniforms.uAmb.value.copy(target.ambient);
      }
      return;
    }
    cancelAnimationFrame(colorAnimation);
    const starts = targets.map((target) => ({
      item: target.item,
      diffuse: target.item.material.uniforms.uDiff.value.clone(),
      ambient: target.item.material.uniforms.uAmb.value.clone(),
    }));
    const begin = performance.now();
    const step = (now) => {
      const t = Math.min(1, (now - begin) / 280);
      const ease = 1 - Math.pow(1 - t, 3);
      for (let i = 0; i < targets.length; i++) {
        starts[i].item.material.uniforms.uDiff.value.copy(starts[i].diffuse).lerp(targets[i].diffuse, ease);
        starts[i].item.material.uniforms.uAmb.value.copy(starts[i].ambient).lerp(targets[i].ambient, ease);
      }
      if (t < 1) colorAnimation = requestAnimationFrame(step);
    };
    colorAnimation = requestAnimationFrame(step);
  }

  function setColors(next) {
    applyColors(next || {}, true);
  }

  function dispose() {
    if (disposed) return;
    disposed = true;
    setActive(false);
    cancelAnimationFrame(colorAnimation);
    observer.disconnect?.();
    resizeObserver.disconnect?.();
    document.removeEventListener("visibilitychange", visibility);
    window.removeEventListener("resize", resize);
    for (const geometry of geometries) geometry.dispose();
    for (const item of materials) item.material.dispose();
    for (const texture of textureFor.cache.values()) texture.dispose();
    textureFor.cache.clear();
    white.dispose();
    renderer.dispose();
    renderer.forceContextLoss?.();
    el.remove();
  }

  canvas.addEventListener("webglcontextlost", (event) => {
    event.preventDefault();
    stop();
    // forceContextLoss() during a model change also fires this event. It is
    // not a real failure: the preview is already on its way out, and the new
    // one must not be replaced by an error message.
    if (disposed) return;
    onError(new Error("webgl_context_lost"));
  });
  resize();
  syncActive();
  return { el, setColors, dispose, setActive, play,
    renderOnce() { if (!disposed) { resize(); renderer.render(scene, camera); } },
  };
}
