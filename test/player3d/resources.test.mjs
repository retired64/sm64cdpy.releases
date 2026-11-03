import {test} from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import {fileURLToPath} from 'node:url';
const root=fileURLToPath(new URL('../../assets/player3d/',import.meta.url));
test('every renderer module dependency is local, present and explicitly allowed by Android',()=>{
 const kotlin=fs.readFileSync(new URL('../../android/app/src/main/kotlin/mods/sm64cdpy/Player3DPlugin.kt',import.meta.url),'utf8');
 const seen=new Set();
 function visit(name){if(seen.has(name))return;seen.add(name);
  assert.ok(kotlin.includes(`"${name}" -> asset("${name}"`),'Android must serve '+name);
  const source=fs.readFileSync(path.join(root,name),'utf8');
  for(const match of source.matchAll(/(?:import|export)[^;]*?from\s*["']([^"']+)["']/g)){
   assert.ok(match[1].startsWith('./'),'remote modules are forbidden');
   const next=path.posix.normalize(path.posix.join(path.posix.dirname(name),match[1]));
   assert.ok(!next.startsWith('../'));visit(next);
  }
 }
 visit('app.js');assert.equal(seen.size,7);
 assert.ok(!fs.readFileSync(path.join(root,'player3d-index.js'),'utf8').includes('document.'));
});
