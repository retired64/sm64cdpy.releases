import {test} from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import vm from 'node:vm';
const source=fs.readFileSync(new URL('../../assets/player3d/app.js',import.meta.url),'utf8').replace(/^import .*;\n/gm,'');
function deferred(){let resolve,reject;const promise=new Promise((a,b)=>{resolve=a;reject=b;});return {promise,resolve,reject};}
function harness(){
 const game=deferred(),states=[],built=[],previews=[],events={},stage={children:[],replaceChildren(...c){this.children=c;},querySelector(){return null;}};
 const window={addEventListener:(name,fn)=>events[name]=fn,matchMedia:()=>({matches:false})};
 let fail=false;
 const context={window,document:{getElementById:()=>stage,createElement:()=>({})},
  Player3DBridge:{postState:s=>states.push(JSON.parse(s))},
  fetch:async path=>{if(path.includes('source-key'))return {ok:true,text:async()=> 'source-A'};
   if(path.includes('game.bin')){await game.promise;if(fail){fail=false;throw Error('offline_local');}}
   return {ok:true,arrayBuffer:async()=>new Uint8Array([1,2,3]).buffer};},
  GameParser:class{constructor(g,rom){this.rom=rom;}},animationForRom:()=>()=>0,
  buildPlayerModel:(_p,index)=>{built.push(index);return {version:4,character:index,pose:[0,0,0],textures:[],groups:[{node:1,pos:Array(9).fill(0),nrm:Array(9).fill(0),uv0:Array(6).fill(0),uv1:Array(6).fill(0),tex:[0,0],wrap:[0,0,0,0],combine:[0,0],env:[255,255,255,255],prim:[255,255,255,255]}],nodes:[{parent:-1,joint:-1,local:Array(16).fill(0)},{parent:0,joint:0,local:Array(16).fill(0)}]};},
  readIdleClips:()=>{throw Error('optional_clips_unavailable');},decodeClip:()=>{},
  marioPreview:(model,colors,options)=>{const p={el:{model:model.character},disposed:false,active:[],palettes:[colors],options,setActive(v){this.active.push(v);},dispose(){this.disposed=true;},setColors(c){this.palettes.push(c);},renderOnce(){}};previews.push(p);return p;},
  requestAnimationFrame:()=>1,cancelAnimationFrame:()=>{},setTimeout:()=>1,clearTimeout:()=>{},
 };
 vm.runInNewContext(source,context,{filename:'app.js'});
 return {window,states,built,previews,events,stage,game,failNext:()=>fail=true};
}
const profile=(model,color=0x123456)=>({model,colors:Array(8).fill(color)});
test('rapid model/palette updates coalesce, obsolete extraction never replaces latest profile',async()=>{
 const h=harness();const first=h.window.player3dUpdate(profile(0));
 await new Promise(resolve=>setImmediate(resolve));
 h.window.player3dUpdate(profile(1));h.window.player3dUpdate(profile(4,0xabcdef));
 h.game.resolve();await first;
 assert.deepEqual(h.built,[4]);assert.equal(h.previews.length,1);
 assert.equal(h.stage.children[0].model,4);assert.equal(h.previews[0].palettes[0].pants,'#abcdef');
 assert.equal(h.states.at(-1).state,'ready');
});
test('palette-only updates reuse preview; its later WebGL failure is still reported',async()=>{
 const h=harness();h.game.resolve();await h.window.player3dUpdate(profile(0));
 await h.window.player3dUpdate(profile(0,0xffffff));assert.equal(h.previews.length,1);
 assert.equal(h.previews[0].palettes.at(-1).pants,'#ffffff');
 h.previews[0].options.onError(Error('context_lost'));assert.equal(h.states.at(-1).state,'error');
});
test('failed local input can retry and optional animation failure still shows model',async()=>{
 const h=harness();h.failNext();h.game.resolve();await h.window.player3dUpdate(profile(0));
 assert.equal(h.states.at(-1).state,'error');await h.window.player3dUpdate(profile(1));
 assert.equal(h.states.at(-1).state,'ready');assert.equal(h.previews.at(-1).options.clips,null);
});
test('page teardown rejects pending input and releases current renderer',async()=>{
 const h=harness(),pending=h.window.player3dUpdate(profile(0));h.events.pagehide();h.game.resolve();await pending;
 assert.equal(h.previews.length,0);
 const k=harness();k.game.resolve();await k.window.player3dUpdate(profile(0));k.events.pagehide();
 assert.equal(k.previews[0].disposed,true);await k.window.player3dUpdate(profile(1));assert.equal(k.previews.length,1);
});
