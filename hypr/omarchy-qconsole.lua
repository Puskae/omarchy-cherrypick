-- Omarchy 4.0's Quake console, cherry-picked onto stock Hyprland.
-- Source: omarchy default/hypr/qconsole.lua
--
-- This turns the scratchpad the bindings already toggle (SUPER + S, and
-- SUPER + section on a Finnish layout) into a drop-down console: it slides in
-- from the top over whatever workspace you are on, covering the top half of the
-- screen, and dims what is underneath instead of switching away from it.
--
-- Nothing here needs the Omarchy runtime. Upstream seeds an empty console with
-- `omarchy-agent`; this seeds a terminal.

-- How much of the usable screen the console covers, measured from the top.
local share = 0.5

-- The terminal to open when the console is toggled on while empty. The exec
-- rule has to name the workspace itself: Hyprland only tags a spawn with the
-- workspace it came from while misc.initial_workspace_tracking is on, and
-- omarchy-looknfeel.lua turns that off.
local seed = "[workspace special:scratchpad silent] alacritty"

-- Dimming only applies while a special workspace is open, so the console is set
-- apart from the workspace underneath at no cost the rest of the time.
--
-- This is global, so it dims behind the Discord overlay (SUPER + D) too. Over a
-- fullscreen game that reads as the game darkening while chat is up; set this
-- to 0 if you would rather it did not.
hl.config({
  decoration = {
    dim_special = 0.6,
  },
})

-- Refitting replaces the rule in place rather than stacking a new one, but it
-- still schedules a monitor and window state refresh, and monitor.focused fires
-- on every hop between screens. Most of those hops do not change the number, so
-- only write the rule when it actually moves.
local covering = nil

local function cover(bottom)
  if covering == bottom then
    return
  end
  covering = bottom

  hl.workspace_rule({
    workspace = "special:scratchpad",
    gaps_in  = 0,
    gaps_out = { top = 0, right = 0, bottom = bottom, left = 0 },

    -- Nothing to highlight in a console that is only ever focused when it is
    -- open, and the active border reads as a stray frame around a panel that is
    -- already set apart by the dimming behind it.
    no_border = true,

    on_created_empty = seed,
  })
end

-- Sizing the console with a window rule would freeze it at whatever the screen
-- measured when the window first mapped, because Hyprland resolves those
-- expressions once. Rescaling the monitor afterwards would leave a console that
-- is no longer half of anything. Gaps are re-applied by the layout instead, so
-- the console is sized by the gap left underneath it, and that gap is recomputed
-- whenever the monitor layout changes.
local function fit()
  local monitor = hl.get_active_monitor()

  -- A monitor handle whose output has gone away answers nil to every field, and
  -- layout changes are exactly when that happens -- so this also covers reading
  -- height and reserved below.
  if not monitor or not monitor.scale or monitor.scale <= 0 then
    return
  end

  -- Monitor dimensions are physical pixels; gaps are logical, so the scale has
  -- to come out before the reserved area (already logical -- this is the space
  -- waybar takes) comes off.
  local reserved = monitor.reserved
  local usable = monitor.height / monitor.scale - reserved.top - reserved.bottom

  cover(math.max(0, math.floor(usable * (1 - share))))
end

-- Until a monitor can be read, cover the whole work area rather than leaving the
-- console unruled, so it is never seeded without its placement.
cover(0)
fit()

hl.on("monitor.layout_changed", fit)
hl.on("monitor.focused", fit)

-- The direction names the edge the offset is measured from, not where the
-- workspace goes: "slide top" drops it down into view, and "slide bottom"
-- retracts it back up the way a Quake console does.
hl.animation({ leaf = "specialWorkspaceIn",  enabled = true, speed = 3, bezier = "easeOutQuint",   style = "slide top" })
hl.animation({ leaf = "specialWorkspaceOut", enabled = true, speed = 2, bezier = "easeInOutCubic", style = "slide bottom" })
