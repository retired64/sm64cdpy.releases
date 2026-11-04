import {test} from 'node:test';
import assert from 'node:assert/strict';
import {buildPlayerModel,angleMatrix,multiplyMatrices,identityMatrix} from '../../assets/player3d/player3d-model.js';
import {Matrix4} from '../../assets/player3d/vendor/three.core.js';

function fixture() {
 const d=new Uint8Array(2048),dv=new DataView(d.buffer);let at=8;
 const pointers=new Map();
 function command(op,xyz=[],list=0){const here=at;d[at]=op;if(op===19){dv.setInt16(at+2,xyz[0],true);dv.setInt16(at+8,xyz[1],true);dv.setInt16(at+10,xyz[2],true);pointers.set(at+16,list);at+=24;}else at+=8;return here;}
 command(19,[10,20,30],512);command(4);
 command(19,[7,0,0],512);command(5);
 command(19,[0,8,0],512);command(1);
 // One native float vertex batch, one triangle and ENDDL. Same display list is
 // referenced from three nodes to verify batching never merges their ownership.
 dv.setUint32(512,0x01003006,true);pointers.set(520,1024);
 dv.setUint32(528,0x05000204,true);dv.setUint32(544,0xdf000000,true);
 for(let v=0;v<3;v++){const offset=1024+v*24;dv.setFloat32(offset,v,true);dv.setFloat32(offset+4,v+1,true);dv.setFloat32(offset+8,v+2,true);dv.setInt8(offset+19,127);}
 return {d,dv,rom:new Uint8Array(1),off:a=>a>=0&&a<d.length?a:-1,at:a=>a,ptr:a=>pointers.get(a)||0,findActor:()=>8,fromRom:()=>null};
}
test('animated OPEN/CLOSE_NODE nesting, siblings and per-node material batches',()=>{
 const model=buildPlayerModel(fixture(),0,()=>0);
 assert.deepEqual(model.nodes.map(n=>n.parent),[-1,0,1,0]);
 assert.deepEqual(model.nodes.map(n=>n.joint),[-1,0,1,2]);
 assert.equal(model.groups.length,3);assert.deepEqual(model.groups.map(g=>g.node),[1,2,3]);
 assert.deepEqual(model.nodes[1].local.slice(12,15),[10,20,30]);
 assert.deepEqual(model.groups[0].pos,model.groups[1].pos);
});
test('matrix multiplication matches Three.js, preserving local XYZ rotation order',()=>{
 const a=angleMatrix(8000,-12000,2300,[10,20,30]);const b=angleMatrix(-3000,7000,1000,[7,-3,2]);
 const expected=new Matrix4().fromArray(a).multiply(new Matrix4().fromArray(b)).elements;
 multiplyMatrices(a,b).forEach((v,i)=>assert.ok(Math.abs(v-expected[i])<1e-12));
 assert.deepEqual(multiplyMatrices(identityMatrix(),a),a);
});
test('bad indices, unsupported geo and excessive nesting terminate with errors',()=>{
 assert.throws(()=>buildPlayerModel(fixture(),5,()=>0),/model_index/);
 const p=fixture();p.d[8]=255;assert.throws(()=>buildPlayerModel(p,0,()=>0),/geo_command/);
 const q=fixture();q.d.fill(4,8);assert.throws(()=>buildPlayerModel(q,0,()=>0));
});
