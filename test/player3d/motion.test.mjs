import {test} from 'node:test';
import assert from 'node:assert/strict';
import {Object3D,Matrix4} from '../../assets/player3d/vendor/three.core.js';
import {createIdleMotion} from '../../assets/player3d/player3d-renderer.js';
function encoded(values){const b=new Uint8Array(values.length*2),v=new DataView(b.buffer);values.forEach((x,i)=>v.setInt16(i*2,x,true));return Buffer.from(b).toString('base64');}
function rig(reduced=false,corrupt=false){
 const object=new Object3D();object.matrixAutoUpdate=false;
 const clip={id:'a',frames:2,fps:30,rot:encoded([0,32000,0,0,-32000,0]),trans:encoded([0,0,0,0,10,0])};
 const set={joints:1,sequence:['a'],clips:[corrupt?{...clip,rot:''}:clip]};
 const motion=createIdleMotion({pose:[0,0,0]},[{object,node:0,joint:0}],[new Matrix4()],1,set,reduced);
 motion.initialPose();return {motion,object};
}
test('interpolates shortest quaternion arc across signed angle wrap and root translation',()=>{
 const {motion,object}=rig();motion.advance(1/60);
 const m=object.matrix.elements;
 assert.ok(m[0]<-0.99,'halfway rotation stays near 180 degrees, not zero');
 assert.equal(m[13],5,'body translation interpolates with the rotation');
 for(let i=0;i<1000;i++){motion.advance(1/60);assert.ok(object.matrix.elements.every(Number.isFinite));}
});
test('reduced motion freezes first idle frame; explicit play resumes',()=>{
 const {motion,object}=rig(true),first=object.matrix.clone();motion.advance(0.1);
 assert.deepEqual(object.matrix.elements,first.elements);motion.play();motion.advance(1/60);
 assert.notDeepEqual(object.matrix.elements,first.elements);
});
test('invalid or unavailable clips keep the reference pose without throwing',()=>{
 const {motion,object}=rig(false,true);assert.equal(motion.hasClips,false);
 motion.advance(0.1);assert.deepEqual(object.matrix.elements,new Matrix4().elements);
});
