-- ============================================================================
-- JWAIO - Jeckyll Widget All in One
-- Copyright 2026 DrJeckyllMrHyde - SPDX-License-Identifier: Apache-2.0
-- Fichier : lib/diagnostics.lua - Version : 0.3.1 Alpha
-- Role : journal d'evenements prive, horodate au centieme de seconde.
-- Les evenements sont groupes a 1 Hz dans un tampon borne. Aucun acces disque
-- par bip. Une panne de diagnostic ne doit pas interrompre les alertes du widget.
-- ============================================================================

return function(config, util, loggerModule)
  local M = {}
  local watched = {"armed", "prearmed", "beeper", "flip", "rth",
    "gpsValid", "altitudeValid", "speedValid", "batteryValid", "lqValid", "rssiValid", "satsValid"}

  function M.new()
    return {active=false, buffer={}, previous={}, dropped=0, nextFlush=0}
  end

  local function clean(value)
	  local s = tostring(value or "")
	  s = string.gsub(s, "[,\r\n]", " ")
	  s = string.sub(s, 1, 120)
	  return s
	end

  local function writeFile(path, mode, content)
    local opened, handle = pcall(io.open, path, mode)
    if not opened or not handle then return false end
    local written, result = pcall(io.write, handle, content)
    local closed = pcall(io.close, handle)
    return written and result ~= nil and result ~= false and closed
  end

  function M.event(d, now, event, subject, detail)
    if not d.active or d.error then return end
    if #d.buffer >= (config.diagnosticBufferLimit or 64) then
      d.dropped = d.dropped + 1
      return
    end
    d.buffer[#d.buffer+1] = string.format("%.2f,%.2f,%s,%s,%s\n",
      now - d.startedAt, now, clean(event), clean(subject), clean(detail))
  end

  local function flush(d, now)
    if d.error or not d.filename or (#d.buffer == 0 and d.dropped == 0) then return end
    local content = table.concat(d.buffer)
    if d.dropped > 0 then
      content = content .. string.format("%.2f,%.2f,dropped,buffer,%d\n",
        now-d.startedAt, now, d.dropped)
    end
    local ok = writeFile(d.filename, "a", content)
    d.buffer = {}
    d.dropped = 0
    if not ok then d.error = "DIAG WRITE" end
  end

  function M.beginTick(d, state, flightFilename)
    if not config.diagnosticsEnabled then return end
    local requested = state.armed or state.beeper or state.flip or state.rth
    if requested and not d.active then
      d.active = true
      d.error = nil
      d.previous = {}
      d.buffer = {}
      d.dropped = 0
      d.startedAt = state.now
      d.nextFlush = state.now + (config.diagnosticFlushSeconds or 1)
      local found, filename = pcall(loggerModule.availableFilename, "E")
      d.filename = found and filename or nil
      if not d.filename then d.error = "DIAG OPEN"; return end
      local ok = writeFile(d.filename, "w", "elapsed_s,radio_time_s,event,subject,detail\n")
      if not ok then d.error = "DIAG WRITE"; return end
      M.event(d, state.now, "start", "build", config.version .. "-" .. config.iteration)
    end
    if not d.active then return end
    if state.armed and flightFilename and d.flightFilename ~= flightFilename then
      d.flightFilename = flightFilename
      M.event(d, state.now, "flight", "csv", flightFilename)
    end
    for _, key in ipairs(watched) do
      local value = state[key] == true
      if d.previous[key] ~= value then
        M.event(d, state.now, "state", key, value and "1" or "0")
        d.previous[key] = value
      end
    end
  end

  function M.endTick(d, state, finder)
    if not d.active then return end
    local signal = finder and finder.valid and finder.source or "NO_DATA"
    if d.signal ~= signal then
      d.signal = signal
      M.event(d, state.now, "finder", "source", signal)
    end
    local stop = not (state.armed or state.beeper or state.flip or state.rth)
    if stop then M.event(d, state.now, "stop", "session", "") end
    if stop or state.now >= d.nextFlush then
      flush(d, state.now)
      d.nextFlush = state.now + (config.diagnosticFlushSeconds or 1)
    end
    if stop then
      d.active = false
      d.buffer = {}
      d.signal = nil
      d.flightFilename = nil
    end
  end

  return M
end
