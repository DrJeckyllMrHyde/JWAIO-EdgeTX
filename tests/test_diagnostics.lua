local sdRoot = (arg and arg[1]) or 'radios/TX15'
-- JWAIO v0.3.1 Alpha : bornes memoire, I/O, cadence d'ecriture et noms uniques.
local config=assert(loadfile(sdRoot..'/WIDGETS/JWAIO/config.lua'))()
local memory, appends={},0
io={open=function(path,mode)
  if mode=='r' and not memory[path] then return nil end
  if mode=='w' then memory[path]='' end
  if mode=='a' then appends=appends+1 end
  return {path=path}
end, close=function() return true end,
write=function(h,...) memory[h.path]=(memory[h.path] or '')..table.concat({...}); return true end}
local util={fileStamp=function() return '260906_120000' end}
local lm=assert(loadfile(sdRoot..'/WIDGETS/JWAIO/lib/logger.lua'))()(config,util)
local dm=assert(loadfile(sdRoot..'/WIDGETS/JWAIO/lib/diagnostics.lua'))()(config,util,lm)
local d=dm.new(); local s={now=0,armed=true}
dm.beginTick(d,s,'flight.csv'); assert(d.active and not d.error)
for i=1,1000 do dm.event(d,0.01,'test','bounded','x') end
assert(#d.buffer==64 and d.dropped>0)
s.now=0.5; dm.endTick(d,s); assert(appends==0)
s.now=1; dm.endTick(d,s); assert(appends==1 and #d.buffer==0)
assert(memory[d.filename]:find('dropped,buffer,'))
local first=d.filename
s.armed=false; s.now=1.1; dm.beginTick(d,s); dm.endTick(d,s)
assert(not d.active and appends==2)
s.armed=true; s.now=1.2; dm.beginTick(d,s)
assert(d.filename~=first and memory[first]:find('stop,session,'))
-- Une panne du diagnostic ne provoque ni exception ni accumulation memoire.
io.write=function() error('storage unavailable') end
s.now=3; dm.endTick(d,s); assert(d.error=='DIAG WRITE' and #d.buffer==0)
for _=1,1000 do dm.event(d,3,'ignored','x','x') end
assert(#d.buffer==0)
-- La desactivation de diagnostic ne cree aucun fichier.
config.diagnosticsEnabled=false; d=dm.new(); dm.beginTick(d,s); assert(not d.active)
-- Collision saturee : aucun ecrasement silencieux d'un ancien vol.
memory['/LOGS/JWAIO/F260906_120000.csv']='preserved'
for i=1,99 do memory[string.format('/LOGS/JWAIO/F260906_120000_%02d.csv',i)]='preserved' end
local log=lm.new(); assert(not lm.start(log,0) and log.error=='LOG NAMES')
assert(memory['/LOGS/JWAIO/F260906_120000_99.csv']=='preserved')
print('Diagnostics buffer / storage failures / collision tests OK')
