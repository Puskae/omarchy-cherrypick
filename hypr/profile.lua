-- Everything specific to one machine and one user, in one table.
--
-- The point of concentrating it here is that nothing in modules/ should need to
-- know what screen it is driving, what keyboard is plugged in, or which browser
-- you use. Modules read these values from the global `jpu` table, which
-- hyprland.lua builds out of this file before a single module loads. Anything
-- you would have to change to run this config on a different box belongs here;
-- anything you would change because you changed your mind about how the desktop
-- behaves does not.
--
-- The values shipped are the reference setup's. keyboard_layout is the one edit
-- you cannot skip; the monitor block is safe to leave.
--
-- Returned as a table rather than set as globals so that the load order stays
-- obvious: hyprland.lua assigns it before it loads a single module.

return {

  ---- Hardware ----

  -- AW3423DWF: "preferred" lands on 60Hz, so the mode is named explicitly. The
  -- panel has no 120Hz at native width -- 3440x1440 offers 59.97 / 99.98 /
  -- 164.90 only.
  --
  -- Safe to leave as it is on other hardware: hyprland.lua declares a catch-all
  -- monitor with output = "" before this one, so a display that is not DP-3
  -- still comes up at its preferred mode. `hyprctl monitors` names yours.
  monitor = {
    output   = "DP-3",
    mode     = "3440x1440@164.90",
    position = "0x0",
    scale    = 1,
  },

  -- Variable refresh rate: 0 = off, 1 = always, 2 = fullscreen only. 2 on the
  -- AW3423DWF because QD-OLED shifts brightness when the refresh rate swings,
  -- which is very visible on a static desktop and not in a game.
  vrr = 2,

  -- The first layout listed also decides which physical keys the named keysyms
  -- in modules/bindings.lua land on. Three of those binds name Finnish keysyms
  -- (plus, dead_acute, section) -- on any other layout rename them too, see the
  -- README's step 3.
  keyboard_layout = "fi",

  ---- Default applications ----

  -- Referenced by modules/bindings.lua.
  terminal = "alacritty",
  browser  = "firefox",
  files    = "dolphin",
  launcher = "walker",

  ---- Picture-in-picture ----

  -- Firefox names its PiP window in the *system locale*, not in English: on a
  -- Finnish system the title is "Kuva kuvassa", so a "Picture-in-Picture"-only
  -- rule matches nothing at all and every PiP setting in modules/windows.lua is
  -- silently dead. Add your language's title from `hyprctl clients` while a PiP
  -- window is open.
  --
  -- Hyprland regex, not a Lua pattern. Shared by the window rule in
  -- modules/windows.lua and the overlay toggle in modules/bindings.lua, which
  -- passes it to hl.get_window("title:" .. this) -- the selector takes the same
  -- dialect as a rule match, so there is one pattern rather than two that can
  -- drift.
  pip_title = "(Picture.?in.?[Pp]icture|Kuva kuvassa)",

  ---- Autostart ----

  -- Applications launched at session start. modules/autostart.lua turns each
  -- entry into both the exec_cmd that starts it and, when `class` and
  -- `workspace` are given, the window rule that parks it there -- so an app is
  -- one line here instead of an edit in two files with a class string
  -- duplicated between them.
  --
  --   cmd          what to run
  --   class        regex matched against the window's class -- Hyprland's own
  --                regex, not a Lua pattern, so a literal dot is "\\." here.
  --                Take it from `hyprctl clients` on a running window, NOT from
  --                the .desktop file's StartupWMClass, which is routinely wrong.
  --   workspace    where to park it. Always applied `silent`: nothing launched
  --                at login should pull the workspace out from under you while
  --                you are already typing.
  --   never_focus  optional. Also refuses the app's *activation requests*, so
  --                it can never raise itself after the fact. Leave it off for
  --                anything you want a notification click to bring forward.
  autostart = {
    { cmd = "alacritty" },

    -- Discord on the SUPER + D overlay (see the README). Its placement is
    -- already a rule in modules/windows.lua, so only never_focus is added here:
    -- `silent` alone is not enough at login, because Discord's updater
    -- relaunches the app and the relaunched window asks to be activated --
    -- which pulls the whole overlay open over the desktop.
    -- { cmd = "discord", class = "discord", never_focus = true },

    -- { cmd = "steam",       class = "steam", workspace = "4" },
    -- { cmd = "thunderbird", class = "(org\\.mozilla\\.)?[tT]hunderbird", workspace = "5" },
  },
}
