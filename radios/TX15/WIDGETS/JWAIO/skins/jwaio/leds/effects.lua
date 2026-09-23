-- JWAIO v0.3.1 Alpha | Apache-2.0 | Copyright 2026 DrJeckyllMrHyde
-- Effets prets a l'emploi. Un debutant n'a normalement rien a modifier ici :
-- toutes les couleurs et la luminosite se reglent dans leds/config.lua.
-- Priorite : batterie faible/critique > RTH > Finder/Flip > ARM > GPS > PreArm > Ready.
--
-- COMMENT LIRE CE FICHIER :
-- 1. La fonction finale est appelee jusqu'a 10 fois par seconde.
-- 2. Elle choisit UN seul effet selon la priorite ci-dessus.
-- 3. Elle renvoie "frame" : une couleur RGB pour chacune des 20 LEDs.
-- Les valeurs utiles de "state" sont notamment armed, prearmed, rth,
-- finderStrength, batteryLow et satelliteLevel. Elles sont fournies par JWAIO.
local previousSatellite, gpsUntil=nil,0

-- Anciennes positions des manches : elles servent uniquement a mesurer la
-- rapidite du geste et rendre le halo plus vif lors d'un mouvement brusque.
local previousAil,previousEle,previousRud,previousThr=nil,nil,nil,nil

local function stickValue(name)
  -- Lit directement la position physique d'un manche (-1024 a +1024).
  local ok,value=pcall(getValue,name)
  if ok and type(value)=="number" and value==value then return value end
  return 0
end

local function addStickHalo(frame,ring,h,v,delta,color)
  -- Transforme une position de manche en halo sur un anneau de 10 LEDs.
  -- ring=0 est le premier anneau, ring=1 le second.
  local magnitude=math.min(1,math.sqrt(h*h+v*v)/1024)
  -- magnitude vaut 0 au centre et 1 en butee du manche.
  if magnitude<0.01 then return end
  local angle=math.atan2(v,h)
  -- On convertit l'angle (-180..180 degres) en position circulaire 0..9.
  angle=(math.deg(angle)+360)%360
  local center=math.floor(angle/36+0.5)%10+ring*10+1
  -- delta augmente la luminosite lors d'un mouvement rapide, sans jamais
  -- doubler plus de deux fois la puissance du halo.
  local boost=math.min(2,1+(delta or 0)/200)
  local base=math.min(1,magnitude*boost)
  for offset=-2,2 do
    -- La LED centrale est la plus brillante, les deux voisines s'adoucissent.
    local index=((center-1+offset)%10)+ring*10+1
    local level=math.max(0.20,base*math.exp(-0.5*offset*offset))
    frame[index]={color[1]*level,color[2]*level,color[3]*level}
  end
end

return function(state,now,count,config)
  -- GPS : lorsque satelliteLevel arrive a 3, demarrer trois impulsions de
  -- 0,25 seconde, separees par 0,25 seconde (total : 1,5 seconde).
  if state.satelliteLevel==3 and previousSatellite~=3 then gpsUntil=now+1.5 end
  previousSatellite=state.satelliteLevel
  -- frame sera rempli avant le return. Les index Lua commencent a 1.
  local frame={}
  local color=config.colors.ready
  local brightness=0.20+0.55*(1-math.abs((now%3)-1.5)/1.5)
  local filled=count
  local offLevel=0.03
  if state.batteryLow or state.batteryCritical then
    -- LiPo : avertissement a 3,60 V/cellule, critique sous 3,40 V/cellule.
    color=config.colors.critical; brightness=(now%0.6)<0.3 and 1 or 0.06
  elseif state.rth then
    -- RTH passe avant Finder : une situation de retour doit rester evidente.
    color=config.colors.critical
    brightness=0.18+0.62*(1-math.abs((now%3)-1.5)/1.5)
  elseif state.finderActive then
    -- Plus le signal est fort, plus le battement vert est rapide :
    -- loin = calme, pres = tres rapide. Le retour reste lisible sans
    -- connaitre l'ordre physique exact des deux anneaux.
    color=config.colors.finder
    local strength=state.finderValid and math.max(0,math.min(100,state.finderStrength or 0)) or 0
    -- Signal faible : cycle de 1,40 s. Signal fort : cycle de 0,30 s.
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
    -- Le plus grand deplacement depuis la trame precedente devient delta.
    local delta=math.max(math.abs(ail-(previousAil or ail)),math.abs(ele-(previousEle or ele)),
      math.abs(rud-(previousRud or rud)),math.abs(thr-(previousThr or thr)))
    if count>=20 then
      local stickMode=2
      if getStickMode then
        local ok,mode=pcall(getStickMode)
        if ok and (mode==1 or mode==2) then stickMode=mode end
      end
      -- Le cablage des deux anneaux depend du mode de manches EdgeTX.
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
    -- Alterne LED forte / LED faible pendant les trois flashs GPS.
    color=config.colors.satellite; brightness=(now%0.5)<0.25 and 1 or 0.1
  elseif state.prearmed then
    color=config.colors.prearm
    brightness=0.20+0.65*(1-math.abs((now%2)-1))
  end
  for i=1,count do
    -- Toute LED non utilisee par l'effet actif recoit le fond tres discret.
    if not frame[i] then
      local level=i<=filled and brightness or offLevel
      frame[i]={color[1]*level,color[2]*level,color[3]*level}
    end
  end
  -- Le gestionnaire LED applique ensuite frame sur la radio.
  return frame
end
