-- Window rules. Derived from Omarchy 4.0, cherry-picked onto stock Hyprland.
--
-- Placement for autostarted apps is NOT here -- it is generated from
-- jpu.autostart by modules/autostart.lua, next to the command that starts
-- each one.
-- Source: omarchy default/hypr/windows.lua + default/hypr/apps/*.lua
-- Translated from Omarchy's o.window() helper to the stock hl.window_rule API.

-- Omarchy's signature near-opaque default: barely-there transparency that
-- deepens when a window loses focus.
hl.window_rule({
  name  = "omarchy-default-opacity",
  match = { class = ".*" },
  opacity = "0.985 0.96",
})

-- Apps Omarchy exempts, because transparency wrecks video, games and VMs.
-- Later rules win, so these land back on fully opaque.
local opaque = {
  ["omarchy-opaque-browsers"] = "(google-)?[cC]hrom(e|ium)|[bB]rave-browser|[mM]icrosoft-edge|Vivaldi-stable|helium|[fF]irefox|zen|librewolf",
  ["omarchy-opaque-steam"]    = "steam.*",
  ["omarchy-opaque-games"]    = "com.libretro.RetroArch|xfreerdp|qemu.*",
  ["omarchy-opaque-video"]    = "mpv|vlc|imv|org.gnome.Loupe|com.github.rafostar.Clapper",
  ["omarchy-opaque-resolve"]  = "resolve",
}

for name, pattern in pairs(opaque) do
  hl.window_rule({
    name  = name,
    match = { class = pattern },
    opacity = "1.0 1.0",
  })
end

-- Picture-in-picture: opaque, 16:9, no border, and no focus grabbing.
--
-- Deliberately NOT floating and NOT pinned. A PiP window here behaves like any
-- other window -- it tiles, and it stays on the workspace it was opened on --
-- because that is what is wanted most of the time. SUPER + SHIFT + P
-- (bindings.lua) flips the one on screen into a pinned corner overlay and back
-- for the times it is not.
--
-- The title comes from profile.lua because it is locale-dependent: Firefox
-- names this window in the system language, and the stock English-only pattern
-- matches nothing on a non-English system.
hl.window_rule({
  name  = "omarchy-pip",
  match = { title = jpu.pip_title },
  opacity = "1.0 1.0",
  -- Firefox re-requests activation whenever it retitles this window, and with
  -- misc.focus_on_activate on that steals focus mid-typing. Omarchy's answer is
  -- no_focus, which is too blunt: an unfocusable window cannot be dragged or
  -- resized either, so the overlay is nailed to wherever the toggle put it.
  -- suppress_event refuses the *activation request* specifically and leaves the
  -- window as clickable as any other.
  suppress_event = "activatefocus",
  -- ...and it still should not grab focus the moment it pops open, which is
  -- mid-typing by definition. Click it when you want it.
  no_initial_focus = true,
  -- Applies whenever it is floating, whether that came from the overlay toggle
  -- or from SUPER + T and a drag on the corner.
  keep_aspect_ratio = true,
  border_size = 0,
})

-- Google Meet names its PiP window after the meeting instead of calling it
-- "Picture-in-Picture", so the rule above never sees it.
hl.window_rule({
  name  = "omarchy-pip-meet",
  match = { class = "(google-)?[cC]hrom(e|ium)|[bB]rave-browser|[mM]icrosoft-edge|Vivaldi-stable|helium", title = "^Meet - .+" },
  opacity = "1.0 1.0",
  float = true,
  pin   = true,
  -- PiP has no keyboard use -- its controls are all mouse -- and with
  -- misc.focus_on_activate on, a browser asking to activate it steals focus
  -- mid-typing. This is still Omarchy's blunt no_focus, which also stops the
  -- window being dragged or resized; the suppress_event + no_initial_focus
  -- pair in the rule above avoids that, and has not been tried on Meet.
  no_focus = true,
  size  = { 600, 338 },
  keep_aspect_ratio = true,
  border_size = 0,
  move  = { "(monitor_w-window_w-40)", "(monitor_h-window_h-40)" },
})

------------------
--- FLOATING ---
------------------

-- Portal dialogs -- file pickers, screen-share prompts, permission requests --
-- are never anything but a dialog, whatever the app that asked for one titled
-- it. Tiled into the layout they shove the window that opened them aside; this
-- gives them the same centred float Omarchy uses everywhere.
local floating = {
  ["omarchy-float-portal"] = { class = "xdg-desktop-portal-gtk" },
  ["omarchy-float-viewers"] = { class = "imv|mpv|org.gnome.Loupe" },
  ["omarchy-float-pavucontrol"] = { class = "org.pulseaudio.pavucontrol|pavucontrol" },
}

for name, match in pairs(floating) do
  hl.window_rule({
    name   = name,
    match  = match,
    float  = true,
    center = true,
    size   = { 875, 600 },
  })
end

-- GTK/Qt apps that draw their own file chooser rather than going through the
-- portal. Matched on the title, because the class is just the app itself.
hl.window_rule({
  name  = "omarchy-float-file-dialogs",
  match = {
    class = "(sublime_text|DesktopEditors|org.gnome.Nautilus|dolphin|org.kde.dolphin)",
    title = "^(Open.*Files?|Open [F|f]older.*|Save.*Files?|Save.*As|Save|All Files|.*wants to [open|save].*|[C|c]hoose.*)",
  },
  float  = true,
  center = true,
  size   = { 875, 600 },
})

---------------------
--- IDLE INHIBIT ---
---------------------

-- hypridle locks at 10 minutes and blanks at 15, counting keyboard and mouse
-- only -- so a film or a controller-only game gets the lock screen dropped on
-- it mid-scene. These windows hold it off while they are on screen.
hl.window_rule({
  name  = "omarchy-idle-inhibit-media",
  match = { class = "mpv|vlc|imv|org.gnome.Loupe|com.github.rafostar.Clapper|firefox|zen|librewolf|(google-)?[cC]hrom(e|ium)" },
  idle_inhibit = "fullscreen",
})

-- Steam titles, gamescope, and anything running under Proton/Wine. Shared by
-- the two rules below so they cannot drift apart.
local games = "steam_app_.*|gamescope|.*\\.exe"

hl.window_rule({
  name  = "omarchy-idle-inhibit-games",
  match = { class = games },
  idle_inhibit = "always",
})

-- A game gets a workspace of its own, and unlike Steam it does *not* get
-- "silent": launching a game should take you to it.
--
-- "empty" is the first workspace with zero windows, scanning up from 1, so a
-- second game launched while the first is running lands somewhere else on its
-- own. The selector is evaluated when the window opens, so the second game
-- already sees the first one's workspace as occupied.
--
-- float = false because a game that drops out of fullscreen while floating
-- ends up sized to the monitor but positioned at an offset -- full-screen-sized
-- with the borders showing off the bottom-right corner. Tiled, that state
-- cannot happen.
hl.window_rule({
  name  = "omarchy-games-workspace",
  match = { class = games },
  workspace = "empty",
  float = false,
})

-- Steam's own window: floating (its dialogs tile badly), and inhibiting only
-- when Big Picture is fullscreen.
hl.window_rule({
  name  = "omarchy-steam",
  match = { class = "steam" },
  float = true,
  idle_inhibit = "fullscreen",
})

hl.window_rule({
  name  = "omarchy-steam-main",
  match = { class = "steam", title = "Steam" },
  center = true,
  size   = { 1100, 700 },
})

hl.window_rule({
  name  = "omarchy-steam-friends",
  match = { class = "steam", title = "Friends List" },
  size  = { 460, 800 },
})

--------------------
--- LAYER RULES ---
--------------------

-- slurp draws its region picker as a layer named "selection". Animating it puts
-- a fade and a 1px frame on the thing you are trying to aim with.
hl.layer_rule({
  match     = { namespace = "selection" },
  no_anim   = true,
  animation = "none",
})

-------------
--- GAMES ---
-------------

-- Discord lives on its own special workspace. A special workspace draws *over*
-- the current one without switching away from it, so SUPER + D overlays chat on
-- a fullscreen game and dismisses it again -- the game never loses fullscreen
-- and never gets told to redraw, which is what breaks alt-tabbing out of one.
--
-- A rule here rather than an autostart entry, so it applies however Discord was
-- started. profile.lua's commented Discord line adds only never_focus on top.
hl.window_rule({
  name  = "discord-overlay",
  match = { class = "discord" },
  workspace = "special:discord silent",
})

-- Games: fully opaque, and no animation/blur work on the frame they own.
hl.window_rule({
  name  = "games-opaque",
  match = { class = games },
  opacity   = "1.0 1.0",
  no_anim   = true,
  no_blur   = true,
})
