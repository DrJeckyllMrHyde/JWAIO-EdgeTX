-- JWAIO 0.2.1 - capteurs absents/perimes, CSV et menu historique.
-- Lancer depuis la racine avec Lua 5.2+ ou Fengari.
local config=assert(loadfile('sdcard/WIDGETS/JWAIO/config.lua'))()
local util=assert(loadfile('sdcard/WIDGETS/JWAIO/lib/util.lua'))()
local ids={RxBt=1,RQly=2,['1RSS']=3,Alt=4,GPS=5,Sats=6,GSpd=7,ch3=8}
local values={24,100,-60,213,{lat=48,lon=2},23,0.8}
local current,fresh={},{}
local time=0
for i=1,7 do current[i]=true; fresh[i]=true end
getFieldInfo=function(name) return ids[name] and {id=ids[name]} or nil end
getSwitchIndex=function() return 1 end
getSwitchValue=function(id) return false end
getTime=function() return time*100 end
getValue=function(id) return id==8 and -1024 or 0 end
getSourceValue=function(id) return values[id], current[id], fresh[id] end
local dm=assert(loadfile('sdcard/WIDGETS/JWAIO/lib/data.lua'))()(config,util)
local state=dm.new()
local options={Cells=6,LQ=2,Thr=8}
local function step()
  time=time+1.1
  dm.update(state,options)
end
step()
assert(state.gpsValid and state.altitudeValid and state.speedValid and state.satsValid)
assert(state.battery==4 and state.lq==100)
-- Freestyle sans GPS : les nombres conserves ne sont pas des mesures valides.
for i=4,7 do current[i]=false; fresh[i]=false end
step()
assert(state.gpsState=='NO_DATA' and state.lat==nil and state.lon==nil)
assert(state.altitude==nil and state.speed==nil and state.sats==nil)
assert(not state.altitudeValid and not state.speedValid and not state.satsValid)
assert(state.batteryValid and state.lqValid and state.rssiValid)
-- Source encore "current" mais plus "fresh" : pas de fausse mesure.
current[4]=true; fresh[4]=false; step()
assert(not state.altitudeValid)
-- Alt independant, valide et stable : ne pas exiger de GPS ni un changement.
fresh[4]=true; values[4]=0; step()
assert(state.altitudeValid and state.altitude==0 and not state.gpsValid)
for _=1,20 do step() end
assert(state.altitudeValid and state.altitude==0)
values[4]=121; step(); assert(state.altitudeValid and state.altitude==121)
-- Une erreur de lecture ou un NaN ne doivent pas etre journalises.
values[4]=0/0; step(); assert(not state.altitudeValid and state.altitude==nil)
values[4]=121
for i=4,7 do current[i]=true; fresh[i]=true end
values[7]=0; step()
assert(state.gpsState=='GPS OK' and state.speedValid and state.speed==0)

-- Defense du CSV meme si un appelant fournit des nombres avec valid=false.
local savedIo=io
local written
io={open=function() return {} end, close=function() end,
    write=function(handle,...) written=table.concat({...}); return true end}
local lm=assert(loadfile('sdcard/WIDGETS/JWAIO/lib/logger.lua'))()(config,{
  dateText=function() return '2026-09-06' end,
  timeText=function() return '12:00:00' end})
local log={active=true,filename='test.csv',nextWrite=0}
local s={now=1,lat=48,lon=2,altitude=213,speed=0.8,battery=3.7,
  distance=10,totalDistance=20,maxDistance=15,lq=100,sats=23,
  gpsValid=false,altitudeValid=false,speedValid=false,batteryValid=true,
  distanceValid=false,lqValid=true,satsValid=false}
lm.update(log,s)
assert(written=='2026-09-06,12:00:00,,,,,3.70,,,,100,\n',written)
s.now=3; s.altitudeValid=true; s.altitude=0; s.speedValid=true; s.speed=0
lm.update(log,s)
assert(written=='2026-09-06,12:00:00,,,0.0,0.0,3.70,,,,100,\n',written)
io=savedIo

-- Le menu ne doit pas devenir celui de la 0.3 : LQ reste en quatrieme position.
CHOICE=1; VALUE=2; SOURCE=3; SWITCH=4
SMLSIZE=1; MIDSIZE=2; BOLD=16; CENTER=32; RIGHT=64
lcd={RGB=function() return 0 end}
loadScript=function(path) return loadfile('sdcard'..path) end
local main=assert(loadfile('sdcard/WIDGETS/JWAIO/main.lua'))()
local expected={'BatType','Cells','LinkType','LQ','ARM','PreArm','Beeper','Flip','RTH','Thr'}
assert(#main.options==10)
for i,name in ipairs(expected) do assert(main.options[i][1]==name) end
assert(config.version=='0.2.1' and config.iteration=='final-2026-09-06')
print('Telemetry validity / CSV / menu tests OK')

-- Cycle complet du widget : timers, armement, journal, distances et Finder.
local memory={}
io.open=function(path,mode)
  if mode=='r' and not memory[path] then return nil end
  if mode=='w' then memory[path]='' end
  memory[path]=memory[path] or ''
  return {path=path}
end
io.close=function() return true end
io.write=function(h,...) memory[h.path]=memory[h.path]..table.concat({...}); return h end
getDateTime=function() return {year=2026,mon=9,day=6,hour=12,min=0,sec=0} end
local timer1,timer2=15,999
model={getTimer=function(i) return {value=i==0 and timer1 or timer2} end,
  resetTimer=function(i) assert(i==0); timer1=0 end}
SMLSIZE=1; MIDSIZE=2; BOLD=16; CENTER=32; RIGHT=64
local texts={}
lcd.drawText=function(x,y,text) texts[text]=true end
lcd.drawRectangle=function() end
lcd.drawFilledRectangle=function() end
lcd.drawBitmap=function() end
Bitmap={open=function(path) return {path=path} end,getSize=function() return 216,132 end}
playFile=function() return true end
local arm,beeper=false,false
getSwitchValue=function(id) return id==90 and arm or id==91 and beeper or false end
local throttle=-1024
getValue=function(id) return id==8 and throttle or 0 end
options.ARM=90; options.Beeper=91
local widget=main.create({x=0,y=0,w=480,h=320},options)
time=time+1.1; main.refresh(widget)
assert(timer1==0 and timer2==999 and texts['Ready'])
arm=true; time=time+1.1; main.background(widget)
assert(widget.logger.active and not widget.flight.flying)
throttle=-900; time=time+1.1; main.background(widget)
assert(widget.flight.flying and widget.data.distanceValid)
values[7]=36; values[5]={lat=48.00005,lon=2}
time=time+1.1; main.background(widget)
assert(widget.data.totalDistance>0)
beeper=true; time=time+0.1; main.background(widget)
assert(widget.finder and widget.audio.finderActive)
beeper=false; time=time+0.1; main.background(widget)
assert(widget.finder==nil and not widget.audio.finderActive)
arm=false; time=time+1.1; main.background(widget)
assert(not widget.logger.active and timer1==0 and timer2==999)
local lastPosition=memory['/LOGS/JWAIO/lastpos.txt']
assert(lastPosition and memory['/LOGS/JWAIO/lastdistance.txt'])
for i=4,7 do current[i]=false; fresh[i]=false end
time=time+1.1; texts={}; main.refresh(widget)
assert(texts.NO_DATA and state.lastLat and memory['/LOGS/JWAIO/lastpos.txt']==lastPosition)
print('Full widget / timers / logging / distance / Finder lifecycle OK')
