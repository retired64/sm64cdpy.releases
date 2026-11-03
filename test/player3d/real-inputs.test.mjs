import {test} from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import {GameParser,animationForRom} from '../../assets/player3d/player3d-index.js';
import {buildPlayerModel,multiplyMatrices,angleMatrix} from '../../assets/player3d/player3d-model.js';
import {readIdleClips,decodeClip} from '../../assets/player3d/player3d-clips.js';
import {createIdleMotion} from '../../assets/player3d/player3d-renderer.js';
import {Object3D,Matrix4} from '../../assets/player3d/vendor/three.core.js';
const game=process.env.PLAYER3D_GAME,romPath=process.env.PLAYER3D_ROM;
test('private local inputs: all five rigs and full idle cycles remain finite; Mario feet stay planted',
 {skip:!(game&&romPath)},()=>{
 const rom=fs.readFileSync(romPath),parser=new GameParser(fs.readFileSync(game),rom),clips=readIdleClips(rom);
 for(let index=0;index<5;index++){
  const model=buildPlayerModel(parser,index,animationForRom(rom));
  assert.equal(model.nodes.length,21);assert.equal(model.pose.length,60);assert.ok(model.groups.length>0);
  const objects=model.nodes.map(n=>{const o=new Object3D();o.matrixAutoUpdate=false;o.matrix.fromArray(n.local);return o;});
  model.nodes.forEach((n,i)=>{if(n.parent>=0)objects[n.parent].add(objects[i]);});
  const animated=model.nodes.flatMap((n,i)=>n.joint<0?[]:[{object:objects[i],node:i,joint:n.joint}]);
  const motion=createIdleMotion(model,animated,objects.map(o=>o.matrix.clone()),20,clips,false);
  motion.initialPose();
  for(let f=0;f<300;f++){motion.advance(1/30);objects[0].updateMatrixWorld(true);for(const o of objects)assert.ok(o.matrixWorld.elements.every(Number.isFinite));}
  if(index!==0)continue;
  for(const raw of clips.clips){const clip=decodeClip(raw,20),ranges=[[],[]];
   for(const translated of [false,true])for(let frame=0;frame<clip.frames;frame++){
    const world=[];
    for(const n of model.nodes){let local=n.local;
     if(n.joint>=0){const j=frame*60+n.joint*3;const translation=n.joint===0&&translated?Array.from(clip.trans.slice(frame*3,frame*3+3)):[0,0,0];local=multiplyMatrices(local,angleMatrix(...clip.data.slice(j,j+3),translation));}
     world.push(n.parent<0?local:multiplyMatrices(world[n.parent],local));
    }
    model.nodes.forEach((n,i)=>{if(n.joint===15||n.joint===19)ranges[translated?1:0].push(world[i][13]);});
   }
   const excursion=values=>Math.max(...values)-Math.min(...values);
   assert.ok(excursion(ranges[0])>4,'test must detect missing body compensation');
   assert.ok(excursion(ranges[1])<1.5,raw.id+' feet moved too far');
  }
 }
});
