-- JWAIO 0.3 alpha - capteurs absents/perimes, CSV et menu skins.
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
-- Source encore current mais plus fresh : garder la mesure valide entre paquets.
current[4]=true; fresh[4]=false; step()
assert(state.altitudeValid and state.altitude==213)
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
assert(written:sub(1, #('2026-09-06,12:00:00,,,,,3.70,,,,100,'))=='2026-09-06,12:00:00,,,,,3.70,,,,100,',written)
s.now=3; s.altitudeValid=true; s.altitude=0; s.speedValid=true; s.speed=0
lm.update(log,s)
assert(written:sub(1, #('2026-09-06,12:00:00,,,0.0,0.0,3.70,,,,100,'))=='2026-09-06,12:00:00,,,0.0,0.0,3.70,,,,100,',written)
io=savedIo

-- Skin remplace LQ sans depasser les dix options.
CHOICE=1; VALUE=2; SOURCE=3; SWITCH=4
SMLSIZE=1; MIDSIZE=2; BOLD=16; CENTER=32; RIGHT=64
lcd={RGB=function() return 0 end}
loadScript=function(path) return loadfile('sdcard'..path) end
local main=assert(loadfile('sdcard/WIDGETS/JWAIO/main.lua'))()
local expected={'Skin','BatType','Cells','LinkType','ARM','PreArm','Beeper','Flip','RTH','Thr'}
assert(#main.options==10)
for i,name in ipairs(expected) do assert(main.options[i][1]==name) end
assert(config.version=='0.3.0' and config.iteration=='alpha-2')
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

-- Les compteurs du dernier vrai vol survivent a un controle moteur <= 5 %.
local lastMax,lastTotal=widget.distance.maxMeters,widget.distance.totalMeters
arm=true; throttle=-1024; time=time+1.1; main.background(widget)
assert(not widget.flight.flying and widget.distance.maxMeters==lastMax)
assert(widget.distance.totalMeters==lastTotal)
arm=false; time=time+0.1; main.background(widget)

-- Sans GPS, Alt et Speed valides restent visibles. Coordonnees hors plage/NaN.
fresh[4]=true; current[4]=true; values[4]=121
fresh[7]=true; current[7]=true; values[7]=36
time=time+1.1; texts={}; main.refresh(widget)
assert(texts['121 m'] and texts['36.0 km/h'] and not widget.data.gpsValid)
current[5]=true; fresh[5]=true
for _, gps in ipairs({{lat=91,lon=2},{lat=48,lon=181},{lat=0/0,lon=2}}) do
  values[5]=gps; time=time+1.1; main.background(widget)
  assert(not widget.data.gpsValid)
end
current[5]=false; fresh[5]=false

-- Le CSV ajoute ses diagnostics sans changer les douze premieres colonnes.
local function csvRows(content)
  local rows={}
  for line in content:gmatch('[^\n]+') do
    local row={}
    for cell in (line..','):gmatch('(.-),') do row[#row+1]=cell end
    rows[#rows+1]=row
  end
  return rows
end
arm=true; time=time+1.1; main.background(widget)
local filename=widget.logger.filename
-- Sag observe a haute cadence : 3.30 au minimum, puis retour 3.90 a l'ecriture.
values[1]=19.8; time=time+0.2; main.background(widget)
values[1]=23.4; time=time+0.8; main.background(widget)
local rows=csvRows(memory[filename]); local header=rows[1]; local last=rows[#rows]
local col={}; for i,name in ipairs(header) do col[name]=i end
for _,row in ipairs(rows) do assert(#row==#header, 'CSV column alignment') end
assert(last[col.cell_min_v]=='3.30' and last[col.cell_max_v]=='3.90')
assert(last[col.pack_v]=='23.40' and last[col.pack_estimated]=='0')
assert(last[col.lat]=='' and last[col.lon]=='' and last[col.gps_valid]=='0')
assert(last[col.altitude]=='121.0' and last[col.alt_valid]=='1')
assert(last[col.build]=='0.3.0-alpha-2')
values[1]=3.9; time=time+1.1; main.background(widget)
rows=csvRows(memory[filename]); last=rows[#rows]
assert(last[col.pack_v]=='23.40' and last[col.pack_estimated]=='1')

-- Les bips au sol doivent aussi etre journalises apres desarmement.
beeper=true; arm=false; time=time+0.1; main.background(widget)
assert(widget.diagnostics.active and not widget.logger.active)
rows=csvRows(memory[filename]); last=rows[#rows]
assert(last[col.armed]=='0', 'Final disarmed row missing')
local eventPath=widget.diagnostics.filename
for _=1,40 do time=time+0.05; main.background(widget) end
beeper=false; time=time+0.05; main.background(widget)
assert(not widget.diagnostics.active)
local events=memory[eventPath]
assert(events:find('submitted,finderBip,RSSI=') and events:find('stop,session,'))
assert(events:find('state,armed,0'))

-- Choix de skin stable, manifeste invalide ignore, repli sans images.
local sm=assert(loadfile('sdcard/WIDGETS/JWAIO/lib/skin.lua'))()(config)
-- Un second skin virtuel teste le changement sans embarquer de visuel tiers.
local originalLoadScript=loadScript
loadScript=function(path)
  if path=='/WIDGETS/JWAIO/skins/example/skin.lua' then
    return function()
      local example=assert(loadfile('sdcard/WIDGETS/JWAIO/skins/jwaio/skin.lua'))()
      example.id='example'; example.name='Example'; example.slot=2
      return example
    end
  end
  return originalLoadScript(path)
end
dir=function()
  local folders={'example','jwaio','../escape','missing'}; local i=0
  return function() i=i+1; return folders[i] end
end
local catalog=sm.discover()
assert(catalog.choices[1]=='JWAIO' and catalog.choices[2]=='Example')
assert(sm.resolve(catalog,2).id=='example')
assert(sm.resolve(catalog,8).id=='jwaio')
local mainSkins=assert(loadfile('sdcard/WIDGETS/JWAIO/main.lua'))()
-- Eviter les anciens fichiers GPS dans ce test de chargement de skin.
io.read=function() return '' end
local themed=mainSkins.create({x=0,y=0,w=480,h=320},options)
for _=1,20 do
  options.Skin=2; mainSkins.update(themed,options); assert(themed.skin.id=='example')
  options.Skin=1; mainSkins.update(themed,options); assert(themed.skin.id=='jwaio')
end
Bitmap.open=function() return nil end
options.Skin=2; mainSkins.update(themed,options)
assert(themed.images.backgroundError)
time=time+1.1; texts={}; mainSkins.refresh(themed); assert(texts['SKIN ERROR'])
print('Alpha CSV / sag / events / no GPS / skins tests OK')
