import {test} from 'node:test';
import assert from 'node:assert/strict';
import {readIdleClips,decodeClip} from '../../assets/player3d/player3d-clips.js';
import {animationForRom} from '../../assets/player3d/player3d-index.js';

export function fakeRom() {
  const bytes=new Uint8Array(0x4f0000),v=new DataView(bytes.buffer),table=0x4ec000;
  v.setUint32(table,198);
  for(let i=0;i<3;i++) {
    const at=table+0x800+i*0x400;
    v.setUint32(table+8+(0xc3+i)*8,at-table);
    v.setUint16(at,1);v.setInt16(at+2,189);v.setInt16(at+4,0);
    v.setInt16(at+8,2);v.setInt16(at+10,20);
    v.setUint32(at+12,24);v.setUint32(at+16,0x180);
    for(let c=0;c<63;c++) {
      v.setUint16(at+0x180+c*4,2);v.setUint16(at+0x180+c*4+2,c*2);
      v.setInt16(at+24+c*4,c===0?-32768:c*10);
      v.setInt16(at+24+c*4+2,c===0?32767:c*10+1);
    }
  }
  return bytes;
}
test('three ordered NOLOOP clips preserve signed int16, translation and frame-major channels',()=>{
 const data=readIdleClips(fakeRom());assert.equal(data.joints,20);
 assert.deepEqual(data.sequence,['idle-left','idle-right','idle-center']);
 for(const item of data.clips){const c=decodeClip(item,20);assert.equal(c.loop,false);assert.equal(c.fps,30);assert.equal(c.frames,2);
 assert.equal(c.trans[0],-32768);assert.equal(c.trans[3],32767);assert.equal(c.data[0],30);assert.equal(c.data[60],31);}
});
test('fresh reference-pose readers do not consume each other',()=>{
 const rom=fakeRom(),a=animationForRom(rom),b=animationForRom(rom);
 assert.equal(a(),30);assert.equal(a(),40);assert.equal(b(),30);
 assert.equal(animationForRom(new Uint8Array(10)),null);
});
test('reject truncated tables, invalid joints, huge frame counts and invalid channel offsets',()=>{
 assert.throws(()=>readIdleClips(new Uint8Array(20)));
 for(const mutate of [v=>v.setInt16(0x4ec800+10,19),v=>v.setInt16(0x4ec800+8,601),
  v=>v.setUint32(0x4ec800+16,0xffffffff),v=>v.setUint16(0x4ec800+0x180,0)]){
  const rom=fakeRom();mutate(new DataView(rom.buffer));assert.throws(()=>readIdleClips(rom));
 }
});
test('cached clips require exact buffers and bounded time dimensions',()=>{
 const c=readIdleClips(fakeRom()).clips[0];
 assert.throws(()=>decodeClip({...c,rot:c.rot.slice(4)},20));
 assert.throws(()=>decodeClip({...c,fps:0},20));
 assert.throws(()=>decodeClip({...c,frames:601},20));
 assert.throws(()=>decodeClip(c,0));
});
