-- Omarchy 4.0 window rules, cherry-picked onto stock Hyprland.
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

-- Picture-in-picture: opaque, floating, pinned above everything, and parked in
-- the top-right corner at a fixed 16:9. Without the size and move it maps
-- wherever the browser asks, which on an ultrawide is usually the middle of the
-- screen and in the way.
hl.window_rule({
  name  = "omarchy-pip",
  match = { title = "(Picture.?in.?[Pp]icture)" },
  opacity = "1.0 1.0",
  float = true,
  pin   = true,
  -- PiP has no keyboard use -- its controls are all mouse -- and Firefox
  -- re-requests activation whenever the window is retitled. With
  -- misc.focus_on_activate on, that steals focus mid-typing, so refuse it here
  -- instead of turning activation off for every application.
  no_focus = true,
  size  = { 600, 338 },
  keep_aspect_ratio = true,
  border_size = 0,
  move  = { "(monitor_w-window_w-40)", "(monitor_h*0.04)" },
})

-- Google Meet names its PiP window after the meeting instead of calling it
-- "Picture-in-Picture", so the rule above never sees it.
hl.window_rule({
  name  = "omarchy-pip-meet",
  match = { class = "(google-)?[cC]hrom(e|ium)|[bB]rave-browser|[mM]icrosoft-edge|Vivaldi-stable|helium", title = "^Meet - .+" },
  opacity = "1.0 1.0",
  float = true,
  pin   = true,
  -- PiP has no keyboard use -- its controls are all mouse -- and Firefox
  -- re-requests activation whenever the window is retitled. With
  -- misc.focus_on_activate on, that steals focus mid-typing, so refuse it here
  -- instead of turning activation off for every application.
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

hl.window_rule({
  name  = "omarchy-idle-inhibit-games",
  match = { class = "steam_app_.*|gamescope|.*\\.exe" },
  idle_inhibit = "always",
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
hl.window_rule({
  name  = "discord-overlay",
  match = { class = "discord" },
  workspace = "special:discord silent",
})

-- Games: fully opaque, and no animation/blur work on the frame they own.
hl.window_rule({
  name  = "games-opaque",
  match = { class = "steam_app_.*|gamescope|.*\\.exe" },
  opacity   = "1.0 1.0",
  no_anim   = true,
  no_blur   = true,
})
