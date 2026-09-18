-- JWAIO v0.3.1_Alpha | Apache-2.0 | Copyright 2026 DrJeckyllMrHyde
-- Effets originaux inspires des principes des exemples RGBLED : RGB + temps.
-- Aucun acces materiel ici : le gestionnaire borne/valide puis applique.
-- Priorite : batterie critique > Finder > ARM > GPS acquis > PreArm > Ready.
local previousSatellite, gpsUntil=nil,0
return function(state,now,count,config)
  if state.satelliteLevel==3 and previousSatellite~=3 then gpsUntil=now+2 end
  previousSatellite=state.satelliteLevel
  local frame={}
  local color=config.colors.ready
  local brightness=0.25+0.75*(1-math.abs((now%2)-1))
  local filled=count
  if state.batteryCritical then
    color=config.colors.critical; brightness=(now%0.8)<0.4 and 1 or 0.08
  elseif state.finderActive then
    if state.finderValid then
      color=config.colors.finder; brightness=1
      filled=math.floor(math.max(0,math.min(100,state.finderStrength))*count/100+0.5)
    else
      color=config.colors.lost; brightness=(now%1.6)<0.8 and 0.5 or 0.05
    end
  elseif state.armed then color=config.colors.armed; brightness=1
  elseif now<gpsUntil then
    color=config.colors.satellite; brightness=(now%0.5)<0.25 and 1 or 0.1
  elseif state.prearmed then color=config.colors.prearm; brightness=0.7 end
  for i=1,count do
    local level=i<=filled and brightness or 0.03
    frame[i]={color[1]*level,color[2]*level,color[3]*level}
  end
  return frame
end
