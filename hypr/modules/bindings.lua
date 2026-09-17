-- Keybindings. Derived from Omarchy 4.0, cherry-picked onto stock Hyprland.
--
-- This module is the SINGLE owner of every keybind: hl.bind is additive and
-- there is no hl.unbind, so a bind declared in two places fires twice rather
-- than the later one winning.
-- Omarchy drives most of these through omarchy-* helper scripts that aren't
-- installed here, so anything that had a native equivalent was rewritten
-- against the real tool (wpctl, playerctl, grim, makoctl, hyprlock) and
-- anything that didn't was dropped. Drops are listed at the bottom.

local home     = os.getenv("HOME")

-- Default applications come from profile.lua, so swapping the browser is a
-- one-line change in one file rather than a grep through the binds.
local terminal = jpu.terminal
local browser  = jpu.browser
local files    = jpu.files
local launcher = jpu.launcher

-- Every bind goes through this rather than hl.bind, so its description is filed
-- under the section of this file it is declared in: `section = "Windows"` under
-- a banner turns "Toggle floating" into "Windows: Toggle floating". hyprctl
-- binds exposes nothing about a bind but its description, so that prefix is how
-- hypr-cheatsheet groups the sheet without keeping a list of its own.
local section

local function bind(keys, action, opts)
  if opts == nil then return hl.bind(keys, action) end
  if opts.description and section then
    opts.description = section .. ": " .. opts.description
  end
  return hl.bind(keys, action, opts)
end

-- Omarchy binds workspaces and resize keys by keycode (code:20 etc) via its own
-- o.bind helper. Stock hl.bind takes a key string only -- HL.BindOptions has no
-- keycode field -- so "SUPER + code:10" silently registers a bind on a key
-- named "SUPER + code:10" that can never fire.
--
-- No helper is needed here: input:resolve_binds_by_sym is false (the default),
-- so Hyprland resolves each named keysym to a keycode using the *first*
-- configured layout, which is fi. Naming the Finnish keysym therefore binds the
-- physical key Omarchy meant:
--   plus       -> keycode 20  (US "-")
--   dead_acute -> keycode 21  (US "=")
--   section    -> keycode 49  (US "`")

------------
--- APPS ---
------------

section = "Apps"

bind("SUPER + RETURN",         hl.dsp.exec_cmd(terminal), { description = "Terminal" })
bind("SUPER + SHIFT + RETURN", hl.dsp.exec_cmd(browser),  { description = "Browser" })
bind("SUPER + SHIFT + B",      hl.dsp.exec_cmd(browser),  { description = "Browser" })
bind("SUPER + SHIFT + F",      hl.dsp.exec_cmd(files),    { description = "File manager" })
bind("SUPER + SPACE",          hl.dsp.exec_cmd(launcher), { description = "Launcher" })
bind("SUPER + V",              hl.dsp.exec_cmd(launcher .. " -m clipboard"), { description = "Clipboard history" })

bind("SUPER + CTRL + T", hl.dsp.exec_cmd(terminal .. " -e btop"),    { description = "Activity monitor" })
bind("SUPER + CTRL + A", hl.dsp.exec_cmd("pavucontrol"),             { description = "Audio settings" })
bind("SUPER + CTRL + W", hl.dsp.exec_cmd(terminal .. " -e nmtui"),   { description = "Network" })

---------------
--- WINDOWS ---
---------------

section = "Windows"

-- Omarchy binds close to both SUPER + W and SUPER + Q. Only Q is kept here:
-- W sits next to the movement keys and gets hit by accident constantly, and
-- an accidental close is not undoable. Re-add it if you want the pair back.
bind("SUPER + Q", hl.dsp.window.close(), { description = "Close window" })

bind("SUPER + J",       hl.dsp.layout("togglesplit"),                        { description = "Toggle split" })
bind("SUPER + P",       hl.dsp.window.pseudo(),                              { description = "Pseudo window" })
bind("SUPER + T",       hl.dsp.window.float({ action = "toggle" }),          { description = "Toggle floating" })
bind("SUPER + F",       hl.dsp.window.fullscreen({ mode = "fullscreen" }),   { description = "Fullscreen" })
bind("SUPER + ALT + F", hl.dsp.window.fullscreen({ mode = "maximized" }),    { description = "Maximize" })

-- Lists rather than keyed tables from here on wherever a loop generates binds:
-- pairs() order is random, and the cheat sheet shows binds in declared order.
local directions = { { "LEFT", "l" }, { "RIGHT", "r" }, { "UP", "u" }, { "DOWN", "d" } }

-- Focus follows the arrow keys; SHIFT moves the window instead.
for _, d in ipairs(directions) do
  local key, direction = d[1], d[2]
  bind("SUPER + " .. key,           hl.dsp.focus({ direction = direction }),       { description = "Focus " .. key:lower() })
  bind("SUPER + SHIFT + " .. key,   hl.dsp.window.swap({ direction = direction }), { description = "Swap " .. key:lower() })
end

bind("ALT + TAB",         hl.dsp.window.cycle_next(),                { description = "Next window" })
bind("ALT + SHIFT + TAB", hl.dsp.window.cycle_next({ next = false }), { description = "Previous window" })

-- Cycling only moves focus, which does nothing visible when the window you
-- landed on is a floating one sitting under another. Hyprland runs duplicate
-- binds additively, so a second bind on the same key raises it as well.
--
-- Deliberately undescribed: hypr-cheatsheet lists one line per described bind,
-- and these are the same user-facing action as the two above, not another one.
bind("ALT + TAB",         hl.dsp.window.bring_to_top())
bind("ALT + SHIFT + TAB", hl.dsp.window.bring_to_top())

-- Resize, by keycode. Plain = 100px, ALT = 25px, CTRL = 300px. The step goes in
-- the description, or the sheet would show three identical "Shrink width" rows.
local steps = { { "", 100 }, { "ALT + ", 25 }, { "CTRL + ", 300 } }
for _, s in ipairs(steps) do
  local modifier, step = s[1], s[2]
  local by = " (" .. step .. "px)"
  bind("SUPER + " .. modifier .. "plus",               hl.dsp.window.resize({ x = -step, y = 0, relative = true }), { description = "Shrink width" .. by })
  bind("SUPER + " .. modifier .. "dead_acute",         hl.dsp.window.resize({ x = step,  y = 0, relative = true }), { description = "Grow width" .. by })
  bind("SUPER + SHIFT + " .. modifier .. "plus",       hl.dsp.window.resize({ x = 0, y = -step, relative = true }), { description = "Shrink height" .. by })
  bind("SUPER + SHIFT + " .. modifier .. "dead_acute", hl.dsp.window.resize({ x = 0, y = step,  relative = true }), { description = "Grow height" .. by })
end

bind("SUPER + mouse:272", hl.dsp.window.drag(),   { mouse = true, description = "Move window" })
bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true, description = "Resize window" })

-- Grouping (tabbed windows). Its own section: "group" here means Hyprland's
-- tabbed group, which would read as a category name buried in Windows.
section = "Tabbed groups"

bind("SUPER + G",       hl.dsp.group.toggle(),                    { description = "Toggle grouping" })
bind("SUPER + ALT + G", hl.dsp.window.move({ out_of_group = true }), { description = "Move out of group" })
bind("SUPER + CTRL + LEFT",  hl.dsp.group.prev(), { description = "Previous in group" })
bind("SUPER + CTRL + RIGHT", hl.dsp.group.next(), { description = "Next in group" })

for _, d in ipairs(directions) do
  local key, direction = d[1], d[2]
  bind("SUPER + ALT + " .. key, hl.dsp.window.move({ into_group = direction }), { description = "Move into group " .. key:lower() })
end

------------------
--- WORKSPACES ---
------------------

section = "Workspaces"

-- The digits resolve to the number-row keycodes, so this is position-based.
for workspace = 1, 10 do
  local key = tostring(workspace % 10) -- workspace 10 sits on the "0" key
  bind("SUPER + " .. key,               hl.dsp.focus({ workspace = workspace }),       { description = "Workspace " .. workspace })
  bind("SUPER + SHIFT + " .. key,       hl.dsp.window.move({ workspace = workspace }), { description = "Move to workspace " .. workspace })
end

bind("SUPER + TAB",         hl.dsp.focus({ workspace = "e+1" }),      { description = "Next workspace" })
bind("SUPER + SHIFT + TAB", hl.dsp.focus({ workspace = "e-1" }),      { description = "Previous workspace" })
bind("SUPER + CTRL + TAB",  hl.dsp.focus({ workspace = "previous" }), { description = "Former workspace" })

bind("SUPER + mouse_down", hl.dsp.focus({ workspace = "e+1" }), { description = "Next workspace" })
bind("SUPER + mouse_up",   hl.dsp.focus({ workspace = "e-1" }), { description = "Previous workspace" })

-- The thumb buttons, for working one-handed on the mouse. 275 is BTN_SIDE
-- ("back") and 276 is BTN_EXTRA ("forward"), which is the direction they read
-- as under the thumb -- back goes down the workspace list, forward goes up.
--
-- SUPER-modified rather than bare on purpose. Hyprland binds are global with
-- no per-application escape, so a bare mouse:275 would swallow back/forward in
-- every browser and file manager as well. That costs the one-handed case the
-- modifier, which is the trade taken here; drop the "SUPER + " if you would
-- rather have the buttons and lose browser navigation.
bind("SUPER + mouse:275", hl.dsp.focus({ workspace = "e-1" }), { description = "Previous workspace" })
bind("SUPER + mouse:276", hl.dsp.focus({ workspace = "e+1" }), { description = "Next workspace" })

-- Omarchy calls its scratchpad "scratchpad", not the stock "magic".
bind("SUPER + S",             hl.dsp.workspace.toggle_special("scratchpad"),                                    { description = "Toggle scratchpad" })
bind("SUPER + ALT + S",       hl.dsp.window.move({ workspace = "special:scratchpad", follow = false }),          { description = "Move to scratchpad" })
bind("SUPER + section",       hl.dsp.workspace.toggle_special("scratchpad"),                                    { description = "Toggle scratchpad" })

-- Discord overlay: draws over a fullscreen game without unfullscreening it.
bind("SUPER + D", hl.dsp.workspace.toggle_special("discord"), { description = "Discord overlay" })

bind("CTRL + ALT + TAB",         hl.dsp.focus({ monitor = "+1" }), { description = "Next monitor" })
bind("CTRL + ALT + SHIFT + TAB", hl.dsp.focus({ monitor = "-1" }), { description = "Previous monitor" })

-------------
--- MEDIA ---
-------------

section = "Media"

-- Native wpctl/playerctl in place of omarchy-audio-* and omarchy-shell media.
-- No brightness binds: this is a desktop, /sys/class/backlight is empty.
bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true, description = "Volume up" })
bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true, description = "Volume down" })
bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true, description = "Mute" })
bind("XF86AudioMicMute",     hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   { locked = true, description = "Mute microphone" })

-- ALT + volume keys nudge by 1% instead of 5%, as Omarchy does.
bind("ALT + XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 1%+"), { locked = true, repeating = true, description = "Volume up (fine)" })
bind("ALT + XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 1%-"),      { locked = true, repeating = true, description = "Volume down (fine)" })

bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true, description = "Next track" })
bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true, description = "Previous track" })
bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true, description = "Play/pause" })
bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true, description = "Play/pause" })

-------------------
--- SCREENSHOTS ---
-------------------

section = "Screenshots"

-- grim + slurp stand in for omarchy-capture-*. Region shots go to the
-- clipboard; SUPER also writes a timestamped file into the real Pictures
-- directory -- xdg-user-dir resolves it, because hardcoding ~/Pictures
-- creates a stray English folder on a localised system.
bind("PRINT",         hl.dsp.exec_cmd([[grim -g "$(slurp)" - | wl-copy]]),                                              { description = "Screenshot region to clipboard" })
bind("SHIFT + PRINT", hl.dsp.exec_cmd("grim - | wl-copy"),                                                              { description = "Screenshot screen to clipboard" })
bind("SUPER + PRINT", hl.dsp.exec_cmd([[d=$(xdg-user-dir PICTURES 2>/dev/null || echo "$HOME/Pictures"); mkdir -p "$d" && grim -g "$(slurp)" "$d/$(date +%Y%m%d-%H%M%S).png"]]), { description = "Screenshot region to file" })

-- Restored once hyprpicker and wf-recorder were installed.
bind("SUPER + CTRL + PRINT",  hl.dsp.exec_cmd("hyprpicker -a"),                      { description = "Colour picker to clipboard" })
bind("SUPER + ALT + PRINT",   hl.dsp.exec_cmd(home .. "/.local/bin/hypr-record"),   { description = "Toggle screen recording" })

---------------------
--- NOTIFICATIONS ---
---------------------

section = "Notifications"

-- swaync-client in place of omarchy-shell notifications. -sw ("skip wait") on
-- every one of them: without it swaync-client blocks waiting for a daemon that
-- may not be running, and the bind hangs instead of failing.
--
-- SUPER + N is the one worth remembering -- it opens the control centre, which
-- is the whole reason this is swaync and not mako.
bind("SUPER + N",             hl.dsp.exec_cmd("swaync-client -t -sw"),             { description = "Notification centre" })
bind("SUPER + comma",         hl.dsp.exec_cmd("swaync-client --close-latest -sw"), { description = "Dismiss notification" })
bind("SUPER + SHIFT + comma", hl.dsp.exec_cmd("swaync-client -C -sw"),             { description = "Dismiss all notifications" })
bind("SUPER + ALT + comma",   hl.dsp.exec_cmd("swaync-client -a 0 -sw"),           { description = "Invoke last notification" })
bind("SUPER + CTRL + comma",  hl.dsp.exec_cmd("swaync-client -d -sw"),             { description = "Toggle do-not-disturb" })

---------------
--- DISPLAY ---
---------------

section = "Display"

-- Layout toggles. Omarchy drives these through omarchy-hyprland-*-toggle
-- scripts that keep their state in a file under ~/.local/state; there is no
-- runtime here, so they are plain Lua closures instead. State lives for as long
-- as the config does -- a `hyprctl reload` re-runs this file and puts both back
-- to the defaults below.

-- A single window stretched across 3440px is a 3440px-wide text editor. This
-- constrains a lone window on a workspace to a square, leaving the rest as
-- margin.
--
-- Off by default because the setting is global and there is no way to exempt a
-- workspace from it: with it on, the Quake console in modules/qconsole.lua is
-- the only window on its workspace too, so it comes up as a 707x707 square
-- instead of a full-width drop-down. Toggle it on for a session of editing and
-- back off before reaching for the console, or set this to true and accept the
-- square console.
local square_single_window = false

local function apply_single_window_aspect_ratio()
  hl.config({
    layout = {
      -- {0, 0} is the "unset" value Hyprland ships, meaning use the full width.
      single_window_aspect_ratio = square_single_window and { 1, 1 } or { 0, 0 },
    },
  })
end

apply_single_window_aspect_ratio()

bind("SUPER + CTRL + BACKSPACE", function()
  square_single_window = not square_single_window
  apply_single_window_aspect_ratio()
end, { description = "Toggle square single-window aspect" })

-- Gaps and borders off, for a screen share or a video call where every pixel of
-- the shared window counts. The restore values are the ones in
-- modules/looknfeel.lua -- change them there and change them here.
local gaps_hidden = false

bind("SUPER + SHIFT + BACKSPACE", function()
  gaps_hidden = not gaps_hidden
  hl.config({
    general = {
      gaps_in     = gaps_hidden and 0 or 5,
      gaps_out    = gaps_hidden and 0 or 10,
      border_size = gaps_hidden and 0 or 2,
    },
  })
end, { description = "Toggle window gaps" })

-- Cursor zoom, for reading small text on a large screen. CTRL + SHIFT + Z
-- steps back down; the reset avoids having to count presses back.
bind("SUPER + CTRL + Z", function()
  hl.config({ cursor = { zoom_factor = (hl.get_config("cursor.zoom_factor") or 1) + 1 } })
end, { description = "Zoom in" })

bind("SUPER + CTRL + SHIFT + Z", function()
  hl.config({ cursor = { zoom_factor = math.max(1, (hl.get_config("cursor.zoom_factor") or 1) - 1) } })
end, { description = "Zoom out" })

-------------------------
--- PICTURE-IN-PICTURE --
-------------------------

section = "Display"

-- Two things are wanted from a PiP window, at different times, so it is a
-- toggle rather than a window rule.
--
-- Off (the default, and what the rules in modules/windows.lua leave it as):
-- PiP is an ordinary window. It tiles, and it stays on the workspace it was
-- opened on.
--
-- On: floating, pinned -- pinned is Hyprland's "show on every workspace", so
-- the video survives a workspace switch and sits over whatever is there --
-- parked in the top-right corner at 16:9.
--
-- Why this is a Lua function and not a plain hl.dsp.window.pin() bind: every
-- dispatcher acts on the active window by default, and the PiP rule refuses
-- both initial focus and activation requests -- so when this is pressed, the
-- active window is whatever you were typing in, and the naive bind would pin
-- that instead. Each call therefore names the window with `window =`.
-- hl.get_window takes Hyprland's selector syntax, so jpu.pip_title serves both
-- here and as the rule match in windows.lua.
--
-- hl.get_windows({ title = ... }) is NOT an alternative: that filter is an
-- exact string compare, not a regex, and silently returns nothing.
local pip_w, pip_h = 600, 338  -- 16:9
local pip_gap      = 40

bind("SUPER + SHIFT + P", function()
  local pip = hl.get_window("title:" .. jpu.pip_title)
  -- Nothing to toggle. Silent rather than a notification: the answer to a
  -- keypress with no PiP open is that nothing happens.
  if not pip then return end

  -- pin is itself a toggle, so turning the overlay off is pin followed by
  -- dropping back into the layout -- Hyprland remembers the tiled slot.
  if pip.pinned then
    hl.dispatch(hl.dsp.window.pin({ window = pip }))
    hl.dispatch(hl.dsp.window.float({ action = "off", window = pip }))
    return
  end

  hl.dispatch(hl.dsp.window.float({ action = "on", window = pip }))
  hl.dispatch(hl.dsp.window.pin({ window = pip }))
  hl.dispatch(hl.dsp.window.resize({ x = pip_w, y = pip_h, relative = false, window = pip }))

  -- move takes global coordinates, so the monitor's own origin is part of the
  -- sum -- 0,0 on a single screen, but naming it keeps the bind correct if a
  -- second one ever shows up. width/height are the mode, hence the scale
  -- division, and reserved.top is however tall waybar is that day.
  local m = pip.monitor
  if m then
    hl.dispatch(hl.dsp.window.move({
      x = m.x + m.width / m.scale - pip_w - pip_gap,
      y = m.y + (m.reserved and m.reserved.top or 0) + pip_gap,
      relative = false,
      window = pip,
    }))
  end
end, { description = "Toggle PiP overlay" })

-- PiP stays in the Display section of the cheat sheet: one bind is too few to
-- be worth a group of its own.

-- Theme cycling, for flipping through the set to see how one looks. Both
-- directions, because the point is comparing neighbours rather than arriving
-- somewhere: forward past the one you wanted, then straight back. The script
-- reloads everything live and raises a replacing notification naming the
-- theme, so stepping through several does not stack popups. Deliberately not
-- `repeating`: every step reloads Hyprland, waybar, swaync, walker and
-- hyprpaper, and a held key would fire those back to back.
local theme = home .. "/.local/bin/omarchy-theme"
bind("SUPER + SHIFT + T",        hl.dsp.exec_cmd(theme .. " --next"), { description = "Next theme" })
bind("SUPER + CTRL + SHIFT + T", hl.dsp.exec_cmd(theme .. " --prev"), { description = "Previous theme" })

--------------
--- SYSTEM ---
--------------

section = "System"

bind("SUPER + CTRL + L", hl.dsp.exec_cmd("hyprlock"), { description = "Lock" })
bind("SUPER + ESCAPE",   hl.dsp.exec_cmd("wlogout"),  { description = "Power menu" })

-- Reload after editing any of these files.
bind("SUPER + CTRL + R", hl.dsp.exec_cmd("hyprctl reload"), { description = "Reload Hyprland config" })

-- Escape hatch. A launcher overlay that wedges takes keyboard focus with it,
-- and without a terminal already open there is no way back. This kills it.
bind("SUPER + CTRL + ESCAPE", hl.dsp.exec_cmd("pkill -x walker"), { description = "Kill stuck launcher" })

-- Cheat sheet: a walker menu of every described bind, one section at a time.
-- It reads hyprctl binds, so a new bind shows up there under whichever section
-- it was declared in -- see bind() at the top -- with nothing to maintain.
bind("SUPER + K", hl.dsp.exec_cmd(home .. "/.local/bin/hypr-cheatsheet"), { description = "Show keybindings" })

-- Dropped, because they need Omarchy scripts or packages that aren't here:
--   SUPER + SPACE variants beyond the launcher (omarchy-menu)
--   background switcher (a theme's wallpaper comes with it; omarchy-theme
--   sets it, and SUPER + SHIFT + T cycles themes)
