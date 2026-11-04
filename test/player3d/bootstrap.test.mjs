import {test} from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import vm from 'node:vm';
const html=fs.readFileSync(new URL('../../assets/player3d/index.html',import.meta.url),'utf8');
const source=html.match(/<script>\s*([\s\S]*?)<\/script>/)[1];
function bootstrap(){const events={},states=[],timers=new Map();let id=0;
 const window={addEventListener:(event,callback)=>events[event]=callback};
 vm.runInNewContext(source,{window,Player3DBridge:{postState:value=>states.push(JSON.parse(value))},
 setTimeout:(callback)=>{timers.set(++id,callback);return id;},clearTimeout:key=>timers.delete(key)});
 return {window,events,states,timers};
}
test('module import failure reports unavailable even before app.js/bridge-ready',()=>{
 const h=bootstrap();h.events.error({});assert.equal(h.states[0].state,'error');
 assert.equal(h.states[0].detail,'player3d_module_load_failed');assert.equal(h.timers.size,0);
});
test('startup deadline terminates loading; ready and teardown cancel the timer',()=>{
 const h=bootstrap();[...h.timers.values()][0]();assert.equal(h.states[0].detail,'player3d_startup_timeout');
 const k=bootstrap();k.window.player3dStartup.note('ready');assert.equal(k.timers.size,0);
 k.window.player3dStartup.note('loading');assert.equal(k.timers.size,1);k.events.pagehide();
 assert.equal(k.timers.size,0);k.events.error({message:'late'});assert.equal(k.states.length,0);
});
test('unhandled initialization rejection reports a technical error to the existing UI',()=>{
 const h=bootstrap();h.events.unhandledrejection({reason:Error('webgl_failed')});
 assert.equal(h.states[0].detail,'webgl_failed');
});
