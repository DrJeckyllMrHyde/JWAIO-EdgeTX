-- ============================================================================
-- JWAIO - Jeckyll Widget All in One
-- Copyright 2026 DrJeckyllMrHyde
-- SPDX-License-Identifier: Apache-2.0
-- Fichier : lib/flight.lua
-- Version : 0.2.1
-- Role    : transitions ARM, remise a zero TIMER 1 et cycle du journal GPS.
-- ============================================================================

return function(config, loggerModule)
  local M = {}

  function M.new()
    return {
      previousArmed = false,
      flying = false,
      timerReset = false,
      flightSeconds = 0,
      totalSeconds = 0
    }
  end

  function M.update(flight, state, logger)
    -- TIMER 1 est le temps du vol courant. Il est remis a zero une seule fois
    -- au demarrage desarme, puis a chaque front descendant du switch ARM.
    if not state.armed and not flight.timerReset then
      if model and model.resetTimer then
        pcall(model.resetTimer, config.flyTimeTimer)
      elseif model and model.setTimer then
        pcall(model.setTimer, config.flyTimeTimer, 0)
      end
      flight.timerReset = true
    elseif state.armed then
      flight.timerReset = false
    end

    flight.flightSeconds = state.armed and (state.flyTime or 0) or 0
    flight.totalSeconds = state.flyTotal or 0

    -- Le front montant ARM ouvre immediatement un nouveau fichier. Les premieres
    -- lignes peuvent avoir des champs vides si le GPS n'est pas encore pret.
    if state.armed and not flight.previousArmed then
      flight.flying = false
      loggerModule.start(logger, state.now)
    end

    -- Le seuil de vrai vol est partage avec le calcul des distances. Une simple
    -- verification des moteurs a faible throttle ne doit pas demarrer un vol.
    if state.armed and not flight.flying and
       state.throttle > (config.distanceStartThrottlePercent or 5) then
      flight.flying = true
    end

    if not state.armed and flight.previousArmed then
      -- Le front descendant ferme le vol et force une derniere sauvegarde de
      -- la position valide connue avant de remettre l'etat de vol a zero.
      loggerModule.stop(logger)
      loggerModule.saveLastPosition(state)
      flight.flying = false
    end

    flight.previousArmed = state.armed
  end

  return M
end
