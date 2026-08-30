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

-- Picture-in-picture: opaque, floating, and pinned above everything.
hl.window_rule({
  name  = "omarchy-pip",
  match = { title = "(Picture.?in.?[Pp]icture)" },
  opacity = "1.0 1.0",
  float = true,
  pin   = true,
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
