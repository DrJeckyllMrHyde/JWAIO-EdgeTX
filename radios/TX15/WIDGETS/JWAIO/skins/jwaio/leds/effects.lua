-- JWAIO v0.3.1_Alpha | Apache-2.0 | Copyright 2026 DrJeckyllMrHyde
-- Effets originaux inspires des principes des exemples RGBLED : RGB + temps.
-- Aucun acces materiel ici : le gestionnaire borne/valide puis applique.
-- Priorite : batterie faible/critique > RTH > Finder/Flip > ARM > GPS > PreArm > Ready.
local previousSatellite, gpsUntil=nil,0

local previousAil,previousEle,previousRud,previousThr=nil,nil,nil,nil

local function stickValue(name)
  -- Meme lecture directe que le script RGBLED de reference. Les sources
  -- physiques sont plus fiables ici que les voies mixees d'un modele.
  local ok,value=pcall(getValue,name)
  if ok and type(value)=="number" and value==value then return value end
  return 0
end

local function addStickHalo(frame,ring,h,v,delta,color)
  local magnitude=math.min(1,math.sqrt(h*h+v*v)/1024)
  if magnitude<0.01 then return end
  local angle=math.atan2(v,h)
  angle=(math.deg(angle)+360)%360
  local center=math.floor(angle/36+0.5)%10+ring*10+1
  local boost=math.min(2,1+(delta or 0)/200)
  local base=math.min(1,magnitude*boost)
  for offset=-2,2 do
    local index=((center-1+offset)%10)+ring*10+1
    local level=math.max(0.20,base*math.exp(-0.5*offset*offset))
    frame[index]={color[1]*level,color[2]*level,color[3]*level}
  end
end

return function(state,now,count,config)
  -- Trois impulsions de 0,25 s, separees par 0,25 s.
  if state.satelliteLevel==3 and previousSatellite~=3 then gpsUntil=now+1.5 end
  previousSatellite=state.satelliteLevel
  local frame={}
  local color=config.colors.ready
  local brightness=0.20+0.55*(1-math.abs((now%3)-1.5)/1.5)
  local filled=count
  local offLevel=0.03
  if state.batteryLow or state.batteryCritical then
    -- LiPo : avertissement a 3,60 V/cellule, critique sous 3,40 V/cellule.
    color=config.colors.critical; brightness=(now%0.6)<0.3 and 1 or 0.06
  elseif state.rth then
    color=config.colors.critical
    brightness=0.18+0.62*(1-math.abs((now%3)-1.5)/1.5)
  elseif state.finderActive then
    -- Plus le signal est fort, plus le battement vert est rapide :
    -- loin = calme, pres = tres rapide. Le retour reste lisible sans
    -- connaitre l'ordre physique exact des deux anneaux.
    color=config.colors.finder
    local strength=state.finderValid and math.max(0,math.min(100,state.finderStrength or 0)) or 0
    local period=1.40-1.10*strength/100
    local phase=(now%period)/period
    brightness=0.08+0.92*(1-math.abs(phase*2-1))
  elseif state.armed then
    -- Reprise de l'effet des deux anneaux de la TX15 : une aura bleue
    -- suit chacun des sticks, en respectant le mode 1 ou 2 de la radio.
    color=config.colors.armed
    brightness=0
    filled=0
    offLevel=0
    local ail,ele=stickValue("ail"),stickValue("ele")
    local rud,thr=stickValue("rud"),stickValue("thr")
    local delta=math.max(math.abs(ail-(previousAil or ail)),math.abs(ele-(previousEle or ele)),
      math.abs(rud-(previousRud or rud)),math.abs(thr-(previousThr or thr)))
    if count>=20 then
      local stickMode=2
      if getStickMode then
        local ok,mode=pcall(getStickMode)
        if ok and (mode==1 or mode==2) then stickMode=mode end
      end
      if stickMode==1 then
        addStickHalo(frame,0,-ail,thr,delta,color)
        addStickHalo(frame,1,rud,-ele,delta,color)
      else
        addStickHalo(frame,0,-ail,ele,delta,color)
        addStickHalo(frame,1,rud,-thr,delta,color)
      end
    end
    previousAil,previousEle,previousRud,previousThr=ail,ele,rud,thr
  elseif now<gpsUntil then
    color=config.colors.satellite; brightness=(now%0.5)<0.25 and 1 or 0.1
  elseif state.prearmed then
    color=config.colors.prearm
    brightness=0.20+0.65*(1-math.abs((now%2)-1))
  end
  for i=1,count do
    if not frame[i] then
      local level=i<=filled and brightness or offLevel
      frame[i]={color[1]*level,color[2]*level,color[3]*level}
    end
  end
  return frame
end
