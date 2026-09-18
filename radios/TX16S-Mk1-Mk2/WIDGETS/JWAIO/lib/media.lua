-- JWAIO v0.3.1_Alpha | Apache-2.0 | Copyright 2026 DrJeckyllMrHyde
-- Pack audio commun uniquement dans SOUNDS/fr/JWAIO.
-- Lecture bornee au chargement ; pas de lecture disque pendant les bips.
return function(config)
  local M = {}
  local function uint(s, p, n)
    if #s < p+n-1 then return nil end
    local v=0
    for i=n-1,0,-1 do v=v*256+s:byte(p+i) end
    return v
  end
  local function duration(path, fallback)
    if not io or not io.open or not io.read or not io.close then return nil end
    local ok, f=pcall(io.open,path,"r")
    if not ok or not f then return nil end
    local signatureOk=false
    local good, seconds=pcall(function()
      -- La signature ASCII reste lisible meme si l'API ne restitue pas
      -- integralement les octets nuls des champs binaires WAV.
      local signature=io.read(f,4)
      if signature~="RIFF" then return nil end
      signatureOk=true
      local h=io.read(f,8)
      if type(h)~="string" or #h~=8 or h:sub(5,8)~="WAVE" then return nil end
      local bytes, scanned= nil,12
      for _=1,32 do
        h=io.read(f,8)
        if type(h)~="string" or #h~=8 then return nil end
        local size=uint(h,5,4)
        if h:sub(1,4)=="data" then
          if bytes and size>0 then return size/bytes end
          return nil
        end
        if size>16384 or scanned+size>65536 then return nil end
        local chunk=io.read(f,size+size%2)
        if type(chunk)~="string" or #chunk~=size+size%2 then return nil end
        if h:sub(1,4)=="fmt " then
          if #chunk<16 or uint(chunk,1,2)~=1 or uint(chunk,3,2)~=1 or
            uint(chunk,5,4)~=32000 or uint(chunk,15,2)~=16 or
            uint(chunk,13,2)~=2 or uint(chunk,9,4)~=64000 then return nil end
          bytes=64000
        end
        scanned=scanned+8+#chunk
      end
    end)
    pcall(io.close,f)
    if good and type(seconds)=="number" and seconds>0 and seconds<=120 then return seconds end
    -- Une duree illisible ne doit pas rendre muets le skin ET son secours.
    -- EdgeTX reste responsable du decodage audio. Les durees du pack livre
    -- ont ete mesurees sur ordinateur ; aucun acces disque pendant lecture.
    if signatureOk and type(fallback)=="number" and fallback>0 and fallback<=120 then
      return fallback
    end
  end
  function M.load()
    local assets={}
    for kind, base in pairs(config.sounds) do
      local name=base..config.audioExtension
      local path=config.soundPath.."/"..name
      local defaultDuration=config.soundDurations and config.soundDurations[kind]
      local seconds=#path<=36 and duration(path,defaultDuration) or nil
      if kind=="finderBip" and seconds and seconds>0.5 then seconds=nil end
      if seconds then
        assets[kind]={path=path,duration=seconds}
      end
    end
    return assets
  end
  return M
end
