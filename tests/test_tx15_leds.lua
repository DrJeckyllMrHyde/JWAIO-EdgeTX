-- TX15 LED update: simulated RGBLED API, priorities, sticks and failure paths.
local root='radios/TX15'
loadScript=function(path) return loadfile(root..path) end
local skin={path='/WIDGETS/JWAIO/skins/jwaio'}
local factory=assert(loadfile(root..'/WIDGETS/JWAIO/lib/leds.lua'))()
local cfg=assert(loadfile(root..skin.path..'/leds/config.lua'))()
assert(cfg.enabled==1 and cfg.count==20 and cfg.brightness==30 and cfg.fps==10)
assert(cfg.colors.ready[1]==242 and cfg.colors.ready[2]==244 and cfg.colors.ready[3]==255)
local module=factory()
assert(module.load(skin).status=='UNAVAILABLE')
local writes,applied={},0
LED_STRIP_LENGTH=20
setRGBLedColor=function(i,r,g,b)
  assert(i>=0 and i<LED_STRIP_LENGTH and i%1==0)
  for _,v in ipairs({r,g,b}) do assert(v>=0 and v<=255 and v%1==0) end
  writes[i]={r,g,b}
end
applyRGBLedColors=function() applied=applied+1 end
local sticks={ail=0,ele=0,rud=0,thr=0}
getValue=function(name) return sticks[name] or 0 end
local mode=2
getStickMode=function() return mode end
local led=module.load(skin)
assert(led.active and led.count==20)
local state={now=0,armed=false,prearmed=false,batteryValid=true,battery=3.9,
 batteryProfile={warn=3.6,critical=3.4},beeper=false,flip=false,rth=false}
local function step(t) state.now=t;module.update(led,state,nil,nil);assert(led.status=='ON') end
step(0)
assert(writes[0][1]>0 and applied==1)
step(0.01);assert(applied==1,'10 Hz throttle')
state.armed=true;sticks.ail=1024;step(1)
local lit=0
for i=0,19 do if writes[i][3]>0 then lit=lit+1 end end
assert(lit==5,'One active stick lights five LEDs')
local function peakBlue(first,last)
  local peak=first
  for i=first+1,last do if writes[i][3]>writes[peak][3] then peak=i end end
  return peak
end
assert(peakBlue(0,9)==5,'Aileron direction matches corrected ring wiring')
sticks.ail=0;sticks.thr=-1024;mode=1;step(2)
assert(writes[0][3]+writes[1][3]+writes[2][3]+writes[3][3]+writes[4][3]+writes[5][3]+writes[6][3]+writes[7][3]+writes[8][3]+writes[9][3]>0)
for i=10,19 do assert(writes[i][3]==0,'Mode 1 throttle belongs to first ring') end
assert(peakBlue(0,9)==8,'Mode 1 throttle direction')
mode=2;step(3)
for i=0,9 do assert(writes[i][3]==0,'Mode 2 throttle belongs to second ring') end
assert(peakBlue(10,19)==13,'Mode 2 throttle direction')
state.beeper=true;step(4)
assert(writes[0][2]>0 and writes[0][1]==0,'Finder priority over armed')
state.rth=true;step(5)
assert(writes[0][1]>0 and writes[0][2]==0,'RTH priority over Finder')
state.battery=3.5;step(6.1)
assert(writes[0][1]==77 and writes[0][2]==0,'Low battery priority, brightness scaling')
local second=module.load(skin)
module.update(second,state,nil,nil);assert(second.status=='IN USE')
module.stop(led)
for i=0,19 do assert(writes[i][1]+writes[i][2]+writes[i][3]==0) end
assert(not led.active)
setRGBLedColor=function() return false end
module.update(second,{now=7},nil,nil)
assert(not second.active and second.status=='API ERROR')
-- The manager validates RGB components before sending a malformed frame.
setRGBLedColor=function() error('Must not write invalid frame') end
local bad=factory();local invalid=bad.load(skin)
invalid.render=function() return {{-1,0,0}} end
bad.update(invalid,{now=8},nil,nil)
assert(not invalid.active and invalid.status=='EFFECT ERROR')
print('TX15 LEDs: defaults, frame bounds, cadence, sticks, priorities, ownership and errors OK')
