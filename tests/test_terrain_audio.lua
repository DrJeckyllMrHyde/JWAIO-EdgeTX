-- JWAIO 0.2.1 - regressions du retour terrain : scenarios et horloge simules.
-- Executer a la racine : fengari tests/test_terrain_audio.lua (ou Lua 5.2+).
local configFactory = assert(loadfile("sdcard/WIDGETS/JWAIO/config.lua"))
local audioFactory = assert(loadfile("sdcard/WIDGETS/JWAIO/lib/audio.lua"))()
local finderFactory = assert(loadfile("sdcard/WIDGETS/JWAIO/lib/finder.lua"))()
local util = assert(loadfile("sdcard/WIDGETS/JWAIO/lib/util.lua"))()
assert(configFactory().altitudeReference == "sensor", "Choix Alt brut non applique")

local function rig(profile)
  local config = configFactory()
  local audioModule = audioFactory(config)
  local audio = audioModule.new()
  local state = {now=0, mode="ACRO", armed=false, prearmed=false,
    beeper=false, flip=false, rth=false, gpsState="NO_DATA",
    batteryValid=true, battery=3.9, batteryProfile=config.batteryProfiles[profile or 1],
    lqValid=true, lq=100, altitudeValid=true, altitude=238, throttle=0,
    rssiValid=true, rssi=-40}
  local played = {}
  local function step(dt)
    state.now = state.now + dt
    playFile = function(path)
      played[#played+1] = {path=path, time=state.now}
    end
    audioModule.update(audio, state)
  end
  local function run(seconds, dt)
    dt = dt or 0.05
    for _=1, math.floor(seconds/dt+0.5) do step(dt) end
  end
  local function count(name)
    local result=0
    for _, event in ipairs(played) do
      if event.path:match("([^/]+)$") == name then result=result+1 end
    end
    return result
  end
  step(0)
  return config, audioModule, audio, state, step, run, count, played
end

-- Une tension faible continue pendant deux minutes ne produit qu'une annonce.
for profile=1,3 do
  local c, m, a, s, step, run, count = rig(profile)
  s.battery=s.batteryProfile.warn-0.05
  run(120)
  assert(count("batlow.wav")==1, "Repetition batterie faible")
  -- Un rebond court ou NO_DATA ne re-arme pas une annonce deja prononcee.
  s.battery=s.batteryProfile.recover+0.01; run(2)
  s.batteryValid=false; run(4)
  s.batteryValid=true; s.battery=s.batteryProfile.warn-0.05; run(4)
  assert(count("batlow.wav")==1, "Rebond/NO_DATA a rearme l'alerte")
  s.battery=s.batteryProfile.recover+0.01; run(6)
  s.battery=s.batteryProfile.warn-0.05; run(3)
  assert(count("batlow.wav")==2, "Nouvel episode non annonce")
  s.battery=s.batteryProfile.critical-0.05; run(3)
  assert(count("batcrt.wav")==1)
  for _=1,20 do
    s.battery=s.batteryProfile.critical+0.01; run(0.2)
    s.battery=s.batteryProfile.critical-0.01; run(1.5)
  end
  assert(count("batcrt.wav")==1, "Oscillation critique repetee")
end

-- Anti-sag : un creux court n'entraine ni avertissement ni alerte critique.
do
  local c,m,a,s,step,run,count=rig()
  s.battery=3.3; run(0.5)
  s.battery=3.9; run(4)
  assert(count("batlow.wav")==0 and count("batcrt.wav")==0)
end

-- Reference relative : 238 -> 359 m, une fois par armement et pas au sol.
do
  local c,m,a,s,step,run,count=rig()
  c.altitudeReference="relative"
  run(3); assert(count("Altitude.wav")==0)
  s.armed=true; run(1)
  s.altitude=358; run(1); assert(count("Altitude.wav")==0)
  s.altitude=359; run(2); assert(count("Altitude.wav")==1)
  s.altitude=360; run(4); assert(count("Altitude.wav")==1)
  s.armed=false; step(0.05)
  s.armed=true; step(0.05)
  s.altitude=481; run(3); assert(count("Altitude.wav")==2)
end

-- Reference capteur configurable : 120 ne declenche pas, 121 declenche.
do
  local c,m,a,s,step,run,count=rig()
  c.altitudeReference="sensor"; s.altitude=120; s.armed=true; run(2)
  assert(count("Altitude.wav")==0)
  s.altitudeValid=false; s.altitude=150; run(2)
  assert(count("Altitude.wav")==0)
  s.altitudeValid=true; s.altitude=121; run(2)
  assert(count("Altitude.wav")==1)
end

-- Aucune reference sol inventee si les premieres valeurs arrivent en vol.
do
  local c,m,a,s,step,run,count=rig()
  c.altitudeReference="relative"
  s.altitudeValid=false; run(5)
  s.armed=true; run(4)
  s.altitudeValid=true; s.altitude=350; run(1)
  assert(a.altitudeBaseline==nil and count("Altitude.wav")==0)
end

-- Finder prioritaire meme lorsque batterie/altitude attendent. Le franchis-
-- sement reste memorise et se joue a la sortie si le vol est encore arme.
do
  local c,m,a,s,step,run,count,played=rig()
  c.altitudeReference="relative"
  s.armed=true; run(1.5)
  s.beeper=true; s.altitude=359; s.battery=3.5
  local finder=finderFactory(c,util)
  local started=s.now
  for _=1,200 do
    step(0.05)
    finder:update(s,function() return m.playFinderBip(a,s.now) end)
  end
  assert(count("finder_bip.wav")>=35, "Cadence trop lente pres du quad")
  assert(count("batlow.wav")==0 and count("Altitude.wav")==0)
  assert(a.queued.altitude and not a.altitudeAnnounced)
  local previous
  for _, event in ipairs(played) do
    if event.time>started then
      assert(event.path:match("finder_bip.wav$"), "Voix parasite en recherche")
      if previous then assert(event.time-previous>=0.199, "Bips superposes") end
      previous=event.time
    end
  end
  s.beeper=false; run(5)
  assert(count("Altitude.wav")==1 and count("batlow.wav")==1)
end

-- Un WAV en cours finit, puis le Finder passe avant toute nouvelle annonce.
do
  local c,m,a,s,step,run,count=rig()
  s.battery=3.3; run(1.2)
  assert(count("batcrt.wav")==1)
  s.flip=true; step(0.01)
  assert(not m.playFinderBip(a,s.now))
  run(2.1); assert(m.playFinderBip(a,s.now))
  s.flip=false; s.rth=true; step(0.01); assert(a.finderActive)
  s.rth=false; step(0.01); assert(not a.finderActive)
end

-- Les alertes differees de batterie s'annulent quand la valeur n'est plus basse.
do
  local c,m,a,s,step,run,count=rig()
  s.beeper=true; s.battery=3.5; run(3)
  assert(a.queued.batteryLow)
  s.battery=3.9; s.beeper=false; run(3)
  assert(count("batlow.wav")==0)
  s.battery=3.5; run(3); assert(count("batlow.wav")==1)
end

-- Ne pas marquer comme prononcee une alerte en echec d'appel playFile.
do
  local c,m,a,s,step,run,count=rig()
  s.battery=3.5; step(0.05)
  s.now=s.now+2
  playFile=function() error("Lecteur indisponible") end
  m.update(a,s)
  assert(not a.batteryLow.announced and a.queued.batteryLow)
  run(2); assert(count("batlow.wav")==1)
end

-- Le filtre repond en fonction du temps, pas du nombre de frames ; apres un
-- changement loin -> proche, le premier bip ne conserve pas l'ancien delai.
do
  local c=configFactory()
  local function response(dt)
    local f=finderFactory(c,util)
    local s={now=0,rssiValid=true,rssi=-110,lqValid=false}
    f:update(s,function() return true end)
    s.rssi=-40
    local beeps=0
    for i=1,math.floor(0.4/dt+0.5) do
      s.now=i*dt
      f:update(s,function() beeps=beeps+1; return true end)
    end
    assert(f.strength>98 and beeps>=1)
    return f.filtered
  end
  assert(math.abs(response(0.02)-response(0.1))<0.00001)
  local f=finderFactory(c,util)
  local s={now=0,rssiValid=true,rssi=-40,lqValid=false}
  local n=0
  f:update(s,function() n=n+1; return true end)
  s.now=0.1; s.rssiValid=false; f:update(s,function() n=n+1 end)
  assert(not f.valid and n==1)
  s.now=0.2; s.lqValid=true; s.lq=100
  f:update(s,function() n=n+1; return true end)
  assert(f.source=="LQ" and f.value==100 and n==2)
end

-- Alt est disponible avant le prochain echantillon GPS/CSV d'une seconde.
do
  local c=configFactory()
  local time, altitude=0,120
  local ids={RxBt=1,RQly=2,["1RSS"]=3,Alt=4,GPS=5,Sats=6,GSpd=7}
  getFieldInfo=function(name) return {id=ids[name] or 0} end
  getTime=function() return time*100 end
  getValue=function() return 0 end
  getSourceValue=function(id)
    local values={24,100,-40,altitude,{lat=48,lon=2},10,0}
    return values[id],true,true
  end
  local m=assert(loadfile("sdcard/WIDGETS/JWAIO/lib/data.lua"))()(c,util)
  local s=m.new()
  m.update(s,{Cells=6}); assert(s.navigationUpdated and s.altitude==120)
  time=0.2; altitude=121
  m.update(s,{Cells=6}); assert(not s.navigationUpdated and s.altitude==121)
end
print("Terrain audio/finder tests OK")

-- Annulations des annonces differees si les capteurs deviennent invalides.
do
  local c,m,a,s,step,run,count=rig()
  a.nextPlay=s.now+20
  s.armed=true; s.altitude=150; s.gpsState='GPS OK'; run(2)
  assert(a.queued.altitude and a.queued.satellite)
  s.altitudeValid=false; s.gpsState='NO_DATA'; run(1)
  assert(not a.queued.altitude and not a.queued.satellite)
  a.nextPlay=s.now; run(5)
  assert(count('Altitude.wav')==0 and count('Satellite.wav')==0)
  s.altitudeValid=true; s.altitude=150; run(5)
  assert(count('Altitude.wav')==1)
end
print('Invalid deferred alerts tests OK')
