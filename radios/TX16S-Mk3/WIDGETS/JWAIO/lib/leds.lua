-- Port TX16S Mk3, 2026-09-11 : adaptation matérielle ; essais physiques requis.
-- JWAIO v0.3.1_Alpha | Apache-2.0 | Copyright 2026 DrJeckyllMrHyde
-- Un proprietaire LED par module ; effets charges uniquement si enabled=1.
-- Le code du skin doit etre de confiance. pcall protege les erreurs, pas une
-- boucle infinie ni un script volontairement malveillant.
return function()
  local M={}
  local ownership=setmetatable({}, {__mode="v"}) -- ne retient pas un widget supprime
  local function number(v) return type(v)=="number" and v==v and math.abs(v)<math.huge end
  local function load(path)
    local ok, chunk=pcall(loadScript,path,"tx")
    if not ok or type(chunk)~="function" then return nil end
    local success,result=pcall(chunk)
    if success then return result end
  end
  function M.stop(led)
    if not led then return end
    if ownership[1]==led then
      -- N'eteindre que les indices effectivement touches par JWAIO.
      for index in pairs(led.written) do pcall(setRGBLedColor,index,0,0,0) end
      if next(led.written) then pcall(applyRGBLedColors) end
      ownership[1]=nil
    end
    led.render=nil; led.active=false; led.previous={}; led.written={}
  end
  function M.load(skin)
    local led={active=false,status="OFF",written={},previous={},nextUpdate=0}
    local cfg=load(skin.path.."/leds/config.lua")
    if type(cfg)~="table" or cfg.enabled~=1 then return led end
    if type(setRGBLedColor)~="function" or type(applyRGBLedColors)~="function" or
      not number(LED_STRIP_LENGTH) or LED_STRIP_LENGTH<1 then
      led.status="UNAVAILABLE"; return led
    end
    -- Mk3 : indices Lua 0..19 = anneaux ; ne jamais toucher 20..25 (boutons).
    if not number(cfg.count) or cfg.count<1 or cfg.count>20 or cfg.count%1~=0 or
      not number(cfg.brightness) or cfg.brightness<0 or cfg.brightness>100 or
      not number(cfg.fps) or cfg.fps<1 or cfg.fps>20 then
      led.status="CONFIG ERROR"; return led
    end
    local render=load(skin.path.."/leds/effects.lua")
    if type(render)~="function" then led.status="EFFECT ERROR"; return led end
    led.render=render; led.config=cfg
    led.count=math.min(cfg.count,math.floor(LED_STRIP_LENGTH))
    led.period=1/cfg.fps; led.active=true; led.status="READY"
    return led
  end
  function M.update(led,state,finder,audio)
    if not led or not led.active then return end
    local now=state.now
    if now<led.nextUpdate then return end
    led.nextUpdate=now+led.period
    if ownership[1] and ownership[1]~=led then led.status="IN USE"; return end
    -- Copie scalaire : l'effet ne recoit pas l'etat mutable du widget.
    local snapshot={armed=state.armed,prearmed=state.prearmed,
      satelliteLevel=state.satelliteLevel,throttle=state.throttle,
      batteryCritical=state.batteryValid and state.batteryProfile and
        state.battery<state.batteryProfile.critical and audio and
        (audio.batteryCritical.announced or audio.queued.batteryCritical) or false,
      finderActive=state.beeper or state.flip or state.rth,
      finderValid=finder and finder.valid or false,
      finderStrength=finder and finder.strength or 0}
    local ok,frame=pcall(led.render,snapshot,now,led.count,led.config)
    if not ok or type(frame)~="table" then M.stop(led); led.status="EFFECT ERROR"; return end
    for i=1,led.count do
      local rgb=frame[i]
      if type(rgb)~="table" then M.stop(led); led.status="EFFECT ERROR"; return end
      for j=1,3 do
        if not number(rgb[j]) or rgb[j]<0 or rgb[j]>255 then
          M.stop(led); led.status="EFFECT ERROR"; return
        end
      end
    end
    ownership[1]=led
    local changed=false
    for i=1,led.count do
      local rgb=frame[i]
      local r=math.floor(rgb[1]*led.config.brightness/100+0.5)
      local g=math.floor(rgb[2]*led.config.brightness/100+0.5)
      local b=math.floor(rgb[3]*led.config.brightness/100+0.5)
      local packed=r*65536+g*256+b
      if led.previous[i]~=packed then
        local success,result=pcall(setRGBLedColor,i-1,r,g,b)
        if not success or result==false then M.stop(led); led.status="API ERROR"; return end
        led.written[i-1]=true; led.previous[i]=packed; changed=true
      end
    end
    if changed then
      local success,result=pcall(applyRGBLedColors)
      if not success or result==false then M.stop(led); led.status="API ERROR"; return end
    end
    led.status="ON"
  end
  return M
end
