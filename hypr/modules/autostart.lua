-- Session startup: daemons first, then applications.
--
-- The applications half is generated from jpu.autostart in profile.lua -- each
-- entry produces both the exec_cmd that launches it and the window rule that
-- places it. Keeping those two together is the whole reason this file exists;
-- split across an autostart block and a window-rules file, they drift, and the
-- failure is silent (the app launches and lands wherever it likes).

hl.on("hyprland.start", function()
  -- Hand systemd and D-Bus the session environment before anything that talks
  -- to a portal starts, or the first such app takes seconds to appear.
  hl.exec_cmd("systemctl --user import-environment $(env | cut -d'=' -f 1)")
  hl.exec_cmd("dbus-update-activation-environment --systemd --all")

  -- Launched directly, not via their systemd units: every one of those is
  -- WantedBy=graphical-session.target (hyprpaper even Requires= it), and
  -- nothing activates that target in a plain, non-uwsm Hyprland session.
  -- Don't "fix" this by switching to systemctl --user start unless the session
  -- moves to uwsm; the units will simply never run.
  hl.exec_cmd("/usr/lib/hyprpolkitagent/hyprpolkitagent")  -- GUI auth prompts
  hl.exec_cmd("hyprpaper")  -- wallpaper

  -- Notification daemon. swaync rather than mako for the control centre: a
  -- panel that lists what you missed and keeps each notification's action
  -- buttons live. mako is still installed as a fallback with a themed config,
  -- but its unit is masked -- both ship a D-Bus activation file claiming
  -- org.freedesktop.Notifications, and without the mask systemd tries to
  -- activate mako while swaync already owns the name. Swapping back therefore
  -- needs `systemctl --user unmask mako.service` as well as this line.
  hl.exec_cmd("swaync")     -- notifications
  hl.exec_cmd("waybar")     -- status bar
  hl.exec_cmd("hypridle")   -- idle -> lock

  -- Walker's backend. Nothing else starts it: the elephant package ships no
  -- systemd unit, and Omarchy enables one it writes itself during an install
  -- that never ran here. Without elephant, walker maps its overlay and sits on
  -- "waiting for elephant" forever while holding keyboard focus -- which
  -- presents as the keyboard having died, not as a launcher bug.
  hl.exec_cmd("elephant")
  hl.exec_cmd("walker --gapplication-service")  -- launcher daemon

  for _, app in ipairs(jpu.autostart) do
    hl.exec_cmd(app.cmd)
  end
end)

-- Window placement for the autostarted applications.
--
-- Declared at load time rather than inside the hyprland.start handler: window
-- rules have to be registered before the window maps, and an app started in
-- that handler can map before a rule added there would land.
--
-- `silent` is not optional. Without it, an app that takes a few seconds to
-- come up yanks you off whatever workspace you started using in the meantime.
--
-- Both rules are optional per entry: an app with no `class` gets launched and
-- nothing else, and one with a class but no workspace can still take
-- never_focus while some other rule decides where it lands.
for _, app in ipairs(jpu.autostart) do
  if app.class and app.workspace then
    hl.window_rule({
      name      = "autostart-" .. app.cmd,
      match     = { class = app.class },
      workspace = app.workspace .. " silent",
    })
  end

  -- `silent` only covers the instant the window maps. An app that asks to be
  -- activated *afterwards* still gets focused, because looknfeel.lua turns
  -- misc.focus_on_activate on -- and for a window parked on a special
  -- workspace, focusing it pulls that overlay open over whatever is on screen.
  -- That is the login-time symptom: placement worked, and the app hauled
  -- itself into view a few seconds later anyway.
  --
  -- Opt-in per app (profile.lua), not blanket: suppressing activation also
  -- kills "click the notification, app comes forward", which is wanted for
  -- mail and not wanted for chat. no_initial_focus goes with it so the window
  -- does not take the keyboard on the frame it appears either.
  if app.class and app.never_focus then
    hl.window_rule({
      name  = "autostart-never-focus-" .. app.cmd,
      match = { class = app.class },
      suppress_event   = "activatefocus",
      no_initial_focus = true,
    })
  end
end
