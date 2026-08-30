-- Omarchy 4.0 keybindings, cherry-picked onto stock Hyprland.
-- Omarchy drives most of these through omarchy-* helper scripts that aren't
-- installed here, so anything that had a native equivalent was rewritten
-- against the real tool (wpctl, playerctl, grim, makoctl, hyprlock) and
-- anything that didn't was dropped. Drops are listed at the bottom.

local home     = os.getenv("HOME")
local terminal = "alacritty"
local browser  = "firefox"
local files    = "dolphin"
local launcher = "walker"

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

---------------
--- LAUNCH ----
---------------

hl.bind("SUPER + RETURN",         hl.dsp.exec_cmd(terminal), { description = "Terminal" })
hl.bind("SUPER + SHIFT + RETURN", hl.dsp.exec_cmd(browser),  { description = "Browser" })
hl.bind("SUPER + SHIFT + B",      hl.dsp.exec_cmd(browser),  { description = "Browser" })
hl.bind("SUPER + SHIFT + F",      hl.dsp.exec_cmd(files),    { description = "File manager" })
hl.bind("SUPER + SPACE",          hl.dsp.exec_cmd(launcher), { description = "Launcher" })

---------------
--- WINDOWS ---
---------------

hl.bind("SUPER + W", hl.dsp.window.close(), { description = "Close window" })
hl.bind("SUPER + Q", hl.dsp.window.close(), { description = "Close window" })

hl.bind("SUPER + J",       hl.dsp.layout("togglesplit"),                        { description = "Toggle split" })
hl.bind("SUPER + P",       hl.dsp.window.pseudo(),                              { description = "Pseudo window" })
hl.bind("SUPER + T",       hl.dsp.window.float({ action = "toggle" }),          { description = "Toggle floating" })
hl.bind("SUPER + F",       hl.dsp.window.fullscreen({ mode = "fullscreen" }),   { description = "Fullscreen" })
hl.bind("SUPER + ALT + F", hl.dsp.window.fullscreen({ mode = "maximized" }),    { description = "Maximize" })

-- Focus follows the arrow keys; SHIFT moves the window instead.
for key, direction in pairs({ LEFT = "l", RIGHT = "r", UP = "u", DOWN = "d" }) do
  hl.bind("SUPER + " .. key,           hl.dsp.focus({ direction = direction }),       { description = "Focus " .. key:lower() })
  hl.bind("SUPER + SHIFT + " .. key,   hl.dsp.window.swap({ direction = direction }), { description = "Swap " .. key:lower() })
  hl.bind("SUPER + ALT + " .. key,     hl.dsp.window.move({ into_group = direction }), { description = "Move into group " .. key:lower() })
end

hl.bind("ALT + TAB",         hl.dsp.window.cycle_next(),                { description = "Next window" })
hl.bind("ALT + SHIFT + TAB", hl.dsp.window.cycle_next({ next = false }), { description = "Previous window" })

-- Grouping (tabbed windows).
hl.bind("SUPER + G",       hl.dsp.group.toggle(),                    { description = "Toggle grouping" })
hl.bind("SUPER + ALT + G", hl.dsp.window.move({ out_of_group = true }), { description = "Move out of group" })
hl.bind("SUPER + CTRL + LEFT",  hl.dsp.group.prev(), { description = "Previous in group" })
hl.bind("SUPER + CTRL + RIGHT", hl.dsp.group.next(), { description = "Next in group" })

-- Resize, by keycode. Plain = 100px, ALT = 25px, CTRL = 300px.
local steps = { [""] = 100, ["ALT + "] = 25, ["CTRL + "] = 300 }
for modifier, step in pairs(steps) do
  hl.bind("SUPER + " .. modifier .. "plus",               hl.dsp.window.resize({ x = -step, y = 0, relative = true }), { description = "Shrink width" })
  hl.bind("SUPER + " .. modifier .. "dead_acute",         hl.dsp.window.resize({ x = step,  y = 0, relative = true }), { description = "Grow width" })
  hl.bind("SUPER + SHIFT + " .. modifier .. "plus",       hl.dsp.window.resize({ x = 0, y = -step, relative = true }), { description = "Shrink height" })
  hl.bind("SUPER + SHIFT + " .. modifier .. "dead_acute", hl.dsp.window.resize({ x = 0, y = step,  relative = true }), { description = "Grow height" })
end

hl.bind("SUPER + mouse:272", hl.dsp.window.drag(),   { mouse = true, description = "Move window" })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true, description = "Resize window" })

------------------
--- WORKSPACES ---
------------------

-- The digits resolve to the number-row keycodes, so this is position-based.
for workspace = 1, 10 do
  local key = tostring(workspace % 10) -- workspace 10 sits on the "0" key
  hl.bind("SUPER + " .. key,               hl.dsp.focus({ workspace = workspace }),       { description = "Workspace " .. workspace })
  hl.bind("SUPER + SHIFT + " .. key,       hl.dsp.window.move({ workspace = workspace }), { description = "Move to workspace " .. workspace })
end

hl.bind("SUPER + TAB",         hl.dsp.focus({ workspace = "e+1" }),      { description = "Next workspace" })
hl.bind("SUPER + SHIFT + TAB", hl.dsp.focus({ workspace = "e-1" }),      { description = "Previous workspace" })
hl.bind("SUPER + CTRL + TAB",  hl.dsp.focus({ workspace = "previous" }), { description = "Former workspace" })

hl.bind("SUPER + mouse_down", hl.dsp.focus({ workspace = "e+1" }), { description = "Next workspace" })
hl.bind("SUPER + mouse_up",   hl.dsp.focus({ workspace = "e-1" }), { description = "Previous workspace" })

-- Omarchy calls its scratchpad "scratchpad", not the stock "magic".
hl.bind("SUPER + S",             hl.dsp.workspace.toggle_special("scratchpad"),                                    { description = "Toggle scratchpad" })
hl.bind("SUPER + ALT + S",       hl.dsp.window.move({ workspace = "special:scratchpad", follow = false }),          { description = "Move to scratchpad" })
hl.bind("SUPER + section",       hl.dsp.workspace.toggle_special("scratchpad"),                                    { description = "Toggle scratchpad" })

hl.bind("CTRL + ALT + TAB",         hl.dsp.focus({ monitor = "+1" }), { description = "Next monitor" })
hl.bind("CTRL + ALT + SHIFT + TAB", hl.dsp.focus({ monitor = "-1" }), { description = "Previous monitor" })

-------------
--- MEDIA ---
-------------

-- Native wpctl/playerctl in place of omarchy-audio-* and omarchy-shell media.
-- No brightness binds: this is a desktop, /sys/class/backlight is empty.
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true, description = "Volume up" })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true, description = "Volume down" })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true, description = "Mute" })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   { locked = true, description = "Mute microphone" })

-- ALT + volume keys nudge by 1% instead of 5%, as Omarchy does.
hl.bind("ALT + XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 1%+"), { locked = true, repeating = true, description = "Volume up (fine)" })
hl.bind("ALT + XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 1%-"),      { locked = true, repeating = true, description = "Volume down (fine)" })

hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true, description = "Next track" })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true, description = "Previous track" })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true, description = "Play/pause" })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true, description = "Play/pause" })

-----------------
--- UTILITIES ---
-----------------

-- grim + slurp stand in for omarchy-capture-*. Region shots go to the
-- clipboard; SUPER also writes a timestamped file into the real Pictures
-- directory -- xdg-user-dir resolves it, because hardcoding ~/Pictures
-- creates a stray English folder on a localised system.
hl.bind("PRINT",         hl.dsp.exec_cmd([[grim -g "$(slurp)" - | wl-copy]]),                                              { description = "Screenshot region to clipboard" })
hl.bind("SHIFT + PRINT", hl.dsp.exec_cmd("grim - | wl-copy"),                                                              { description = "Screenshot screen to clipboard" })
hl.bind("SUPER + PRINT", hl.dsp.exec_cmd([[d=$(xdg-user-dir PICTURES 2>/dev/null || echo "$HOME/Pictures"); mkdir -p "$d" && grim -g "$(slurp)" "$d/$(date +%Y%m%d-%H%M%S).png"]]), { description = "Screenshot region to file" })

-- makoctl in place of omarchy-shell notifications.
hl.bind("SUPER + comma",         hl.dsp.exec_cmd("makoctl dismiss"),           { description = "Dismiss notification" })
hl.bind("SUPER + SHIFT + comma", hl.dsp.exec_cmd("makoctl dismiss --all"),     { description = "Dismiss all notifications" })
hl.bind("SUPER + ALT + comma",   hl.dsp.exec_cmd("makoctl invoke"),            { description = "Invoke last notification" })
hl.bind("SUPER + CTRL + comma",  hl.dsp.exec_cmd("makoctl mode -t do-not-disturb"), { description = "Toggle do-not-disturb" })

hl.bind("SUPER + CTRL + L", hl.dsp.exec_cmd("hyprlock"),                { description = "Lock" })
hl.bind("SUPER + CTRL + T", hl.dsp.exec_cmd(terminal .. " -e btop"),    { description = "Activity monitor" })
hl.bind("SUPER + CTRL + A", hl.dsp.exec_cmd("pavucontrol"),             { description = "Audio settings" })
hl.bind("SUPER + CTRL + W", hl.dsp.exec_cmd(terminal .. " -e nmtui"),   { description = "Network" })

-- Reload after editing any of these files.
hl.bind("SUPER + CTRL + R", hl.dsp.exec_cmd("hyprctl reload"), { description = "Reload Hyprland config" })

-- Escape hatch. A launcher overlay that wedges takes keyboard focus with it,
-- and without a terminal already open there is no way back. This kills it.
hl.bind("SUPER + CTRL + ESCAPE", hl.dsp.exec_cmd("pkill -x walker"), { description = "Kill stuck launcher" })

-- Cheat sheet: every bind above carries a description, so hyprctl can print
-- the list rather than it having to be maintained by hand.
hl.bind("SUPER + K", hl.dsp.exec_cmd(
  terminal .. " -e " .. home .. "/.local/bin/hypr-cheatsheet"
), { description = "Show keybindings" })

-- Discord overlay: draws over a fullscreen game without unfullscreening it.
hl.bind("SUPER + D", hl.dsp.workspace.toggle_special("discord"), { description = "Discord overlay" })

-- Restored once hyprpicker, wf-recorder and wlogout were installed.
hl.bind("SUPER + V",             hl.dsp.exec_cmd(launcher .. " -m clipboard"),          { description = "Clipboard history" })
hl.bind("SUPER + CTRL + PRINT",  hl.dsp.exec_cmd("hyprpicker -a"),                      { description = "Colour picker to clipboard" })
hl.bind("SUPER + ALT + PRINT",   hl.dsp.exec_cmd(home .. "/.local/bin/hypr-record"),   { description = "Toggle screen recording" })
hl.bind("SUPER + ESCAPE",        hl.dsp.exec_cmd("wlogout"),                            { description = "Power menu" })

-- Dropped, because they need Omarchy scripts or packages that aren't here:
--   SUPER + SPACE variants beyond the launcher (omarchy-menu)
--   theme/background switchers (use `omarchy-theme <name>` instead)
