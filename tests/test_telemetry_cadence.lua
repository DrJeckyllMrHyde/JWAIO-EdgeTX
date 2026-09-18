local sdRoot = (arg and arg[1]) or 'radios/TX15'
-- JWAIO v0.3.1 Alpha : validite et cadence sont deux notions distinctes.
-- Reproduit le clignotement observe sur la video, sans modifier le firmware.
local root=sdRoot..'/WIDGETS/JWAIO/'
local config=assert(loadfile(root..'config.lua'))()
local util=assert(loadfile(root..'lib/util.lua'))()
local ids={RxBt=1,RQly=2,['1RSS']=3,Alt=4,GPS=5,Sats=6,GSpd=7,ch3=8}
local values={25.2,100,-45,88,{lat=48,lon=2},9,0}
local current,fresh=true,true
local now=0
getFieldInfo=function(name) return ids[name] and {id=ids[name]} end
getTime=function() return now*100 end
getValue=function(id) return id==8 and -1024 or 999 end
getSwitchValue=function() return false end
getSourceValue=function(id) return values[id],current,fresh end
local dm=assert(loadfile(root..'lib/data.lua'))()(config,util)
local am=assert(loadfile(root..'lib/audio.lua'))()(config)
local fm=assert(loadfile(root..'lib/finder.lua'))()
local state,audio=dm.new(),am.new()
local played={}
playFile=function(path) played[#played+1]=path end
local function count(name)
  local n=0
  for _,path in ipairs(played) do if path:match('([^/]+)$')==name then n=n+1 end end
  return n
end
local function step(dt)
  now=now+dt
  dm.update(state,{Cells=6,Thr=8})
  am.update(audio,state)
end
-- Une minute : current=true tout le temps, fresh alterne toutes les 250 ms.
for i=1,240 do
  fresh=i%2==0
  step(0.25)
  assert(state.batteryValid and state.lqValid and state.rssiValid)
  assert(state.gpsValid and state.satsValid and state.gpsState=='GPS OK')
  assert(state.altitudeValid and state.speedValid and state.speed==0)
end
assert(count('LipLii_full.wav')==1 and count('stl_rs.wav')==1)
assert(count('gps.wav')==0 and count('elrs.wav')==0)
-- Un passage batterie basse reste detecte, sans fresh obligatoire ni repetition.
values[1]=21
for i=1,240 do fresh=i%2==0; step(0.25) end
assert(count('batlow.wav')==1)
-- Recherche : pas de faux trous dans le signal ni de voix parasite.
local finder=fm(config,util)
local bips=0
for i=1,200 do
  fresh=i%2==0; now=now+0.05
  dm.update(state,{Cells=6,Thr=8}); state.beeper=true
  am.update(audio,state)
  finder:update(state,function()
    local ok=am.playFinderBip(audio,now)
    if ok then bips=bips+1 end
    return ok
  end)
  assert(finder.valid)
end
assert(bips>30)
-- Perte effective : current=false, meme si fresh et la valeur restent presents.
current=false; fresh=true; step(1.1)
assert(not state.batteryValid and state.battery==nil and not state.lqValid)
assert(not state.rssiValid and not state.altitudeValid and not state.speedValid)
assert(state.gpsState=='NO_DATA' and state.lat==nil and state.lon==nil)
finder:update(state,function() error('No beep allowed without data') end)
assert(not finder.valid)
-- Retour avec current valide, fresh=false : retour des valeurs, pas besoin de reload.
current=true; fresh=false; step(1.1)
assert(state.batteryValid and state.gpsState=='GPS OK' and state.lqValid)
assert(state.lastLat==48 and state.lastLon==2)
-- Source absente : nil reste invalide, meme si les deux indicateurs sont vrais.
values[1]=nil; fresh=true; step(1.1); assert(not state.batteryValid)
-- Erreur API : ne pas accepter le 999 renvoye par getValue comme repli.
getSourceValue=function() error('sensor API error') end
step(1.1)
assert(not state.batteryValid and not state.rssiValid and not state.gpsValid)
assert(not state.altitudeValid and not state.lqValid)
print('Telemetry cadence / stable display / audio / Finder / loss and recovery: OK')
