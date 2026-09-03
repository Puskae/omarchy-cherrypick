-- Hyprland entry point. Reference: https://wiki.hypr.land/Configuring/Start/
--
-- This file holds only what is specific to *this* machine and session:
-- monitors, autostart, environment, input, and the window rules Hyprland
-- ships as sane defaults. Everything cosmetic lives in the Omarchy modules
-- dofile'd at the bottom, which are loaded last and therefore win.
--
-- Stock settings that those modules override have been deleted rather than
-- left here commented out -- a duplicate that loses is just a lie about what
-- is in effect.


------------------
---- MONITORS ----
------------------

-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = "auto",
})

-- AW3423DWF: "preferred" lands on 60Hz, so name the mode. The panel has no
-- 120Hz at native width -- 3440x1440 offers 59.97 / 99.98 / 164.90 only.
hl.monitor({
    output   = "DP-3",
    mode     = "3440x1440@164.90",
    position = "0x0",
    scale    = 1,
})


---------------------
---- MY PROGRAMS ----
---------------------

-- Only the terminal is referenced here (autostart, below). The browser and
-- file manager live in omarchy-bindings.lua, which declares its own.
local terminal = "alacritty"


-------------------
---- AUTOSTART ----
-------------------

-- See https://wiki.hypr.land/Configuring/Basics/Autostart/

-- Autostart necessary processes (like notifications daemons, status bars, etc.)
-- Or execute your favorite apps at launch like this:
--
hl.on("hyprland.start", function()
  -- Omarchy's slow-app-launch fix: hand systemd and D-Bus the session
  -- environment before anything that talks to a portal starts.
  hl.exec_cmd("systemctl --user import-environment $(env | cut -d'=' -f 1)")
  hl.exec_cmd("dbus-update-activation-environment --systemd --all")

  -- Launched directly, not via their systemd units: every one of those is
  -- WantedBy=graphical-session.target (hyprpaper even Requires= it), and
  -- nothing activates that target in a plain, non-uwsm Hyprland session.
  hl.exec_cmd("/usr/lib/hyprpolkitagent/hyprpolkitagent")  -- GUI auth prompts
  hl.exec_cmd("hyprpaper")  -- wallpaper
  -- Notification daemon. swaync rather than mako for the control centre: a
  -- panel that lists what you missed and keeps each notification's action
  -- buttons live. mako is still shipped as a fallback -- swap this one line
  -- back to hl.exec_cmd("mako") and its config is already there.
  hl.exec_cmd("swaync")     -- notifications
  hl.exec_cmd("waybar")     -- status bar
  hl.exec_cmd("hypridle")   -- idle -> lock

  -- Walker's backend. Nothing else starts it: the elephant package ships no
  -- systemd unit, and Omarchy enables one it writes itself during install.
  -- Without elephant, walker maps its overlay and sits on "waiting for
  -- elephant" forever while holding keyboard focus -- which is what made the
  -- session look like the keyboard had died.
  hl.exec_cmd("elephant")
  hl.exec_cmd("walker --gapplication-service")  -- launcher daemon; walker
                                                -- warns when it is missing

  hl.exec_cmd(terminal)
end)


-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/

-- Name the cursor theme explicitly. With only a size set, Hyprland has no
-- theme to load and falls back to the tiny built-in pointer -- which on a
-- fresh session reads as a broken cursor, not as a missing setting. "Adwaita"
-- is the safe default rather than a preference: adwaita-cursors arrives with
-- adwaita-icon-theme, which gtk3 depends on, which waybar depends on, so it
-- is present on any system that got through the install steps. Swap in any
-- theme under /usr/share/icons that ships a cursors/ directory.
hl.env("XCURSOR_THEME", "Adwaita")
hl.env("XCURSOR_SIZE", "24")

-- No HYPRCURSOR_THEME: hyprcursor themes are a separate format, and with none
-- named Hyprland falls back to the XCursor theme above. The size still applies.
hl.env("HYPRCURSOR_SIZE", "24")

-- MangoHud everywhere, but hidden: MangoHud.conf sets no_display, so the
-- overlay only appears on Shift_R + F12. Saves setting it per game.
hl.env("MANGOHUD", "1")


-----------------------
---- LOOK AND FEEL ----
-----------------------

-- Gaps, borders, rounding, shadow and blur are all set by
-- omarchy-looknfeel.lua. Border colors come from theme.lua. Only the
-- animation master switch is left here, because nothing downstream sets it.
-- Refer to https://wiki.hypr.land/Configuring/Basics/Variables/
hl.config({
    animations = {
        enabled = true,
    },
})

-- Default curves and animations, see https://wiki.hypr.land/Configuring/Advanced-and-Cool/Animations/
hl.curve("easeOutQuint",   { type = "bezier", points = { {0.23, 1},    {0.32, 1}    } })
hl.curve("easeInOutCubic", { type = "bezier", points = { {0.65, 0.05}, {0.36, 1}    } })
hl.curve("linear",         { type = "bezier", points = { {0, 0},       {1, 1}       } })
hl.curve("almostLinear",   { type = "bezier", points = { {0.5, 0.5},   {0.75, 1}    } })
hl.curve("quick",          { type = "bezier", points = { {0.15, 0},    {0.1, 1}     } })

-- Default springs
hl.curve("easy",           { type = "spring", mass = 1, stiffness = 238.1191, dampening = 24.21279333 })

hl.animation({ leaf = "global",        enabled = true,  speed = 10,   bezier = "default" })
hl.animation({ leaf = "border",        enabled = true,  speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows",       enabled = true,  speed = 4.79, spring = "easy" })
hl.animation({ leaf = "windowsIn",     enabled = true,  speed = 4.1,  spring = "easy",         style = "popin 87%" })
hl.animation({ leaf = "windowsOut",    enabled = true,  speed = 1.49, bezier = "linear",       style = "popin 87%" })
hl.animation({ leaf = "fadeIn",        enabled = true,  speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut",       enabled = true,  speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade",          enabled = true,  speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers",        enabled = true,  speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn",      enabled = true,  speed = 4,    bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut",     enabled = true,  speed = 1.5,  bezier = "linear",       style = "fade" })
hl.animation({ leaf = "fadeLayersIn",  enabled = true,  speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true,  speed = 1.39, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces",    enabled = true,  speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesIn",  enabled = true,  speed = 1.21, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesOut", enabled = true,  speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "zoomFactor",    enabled = true,  speed = 7,    bezier = "quick" })

-- dwindle and master are configured in omarchy-looknfeel.lua. This one is not.
-- See https://wiki.hypr.land/Configuring/Layouts/Scrolling-Layout/ for more
hl.config({
    scrolling = {
        fullscreen_on_one_column = true,
    },
})

----------------
----  MISC  ----
----------------

hl.config({
    misc = {
        -- omarchy-looknfeel.lua disables the logo outright; this only governs
        -- which stock wallpaper would be used if one ever were.
        force_default_wallpaper = -1,

        -- Both default to false, which makes a DPMS-blanked screen look like a
        -- dead machine: hypridle's on-resume is then the *only* thing that can
        -- bring the display back, so if it is misconfigured or not running you
        -- are left hammering a keyboard at a black monitor. Omarchy sets both.
        key_press_enables_dpms  = true,
        mouse_move_enables_dpms = true,
    },
})


---------------
---- INPUT ----
---------------

hl.config({
    input = {
        kb_layout  = "fi",
        kb_variant = "",
        kb_model   = "",
        kb_options = "",
        kb_rules   = "",

        follow_mouse = 1,

        sensitivity = 0, -- -1.0 - 1.0, 0 means no modification.

        repeat_rate  = 40,
        repeat_delay = 250,
        numlock_by_default = true,

        touchpad = {
            natural_scroll = false,
        },
    },
})

hl.gesture({
    fingers = 3,
    direction = "horizontal",
    action = "workspace"
})

---------------------
---- KEYBINDINGS ----
---------------------

-- All keybindings now live in omarchy-bindings.lua, dofile'd at the bottom of
-- this file. The stock binds that used to sit here were removed rather than
-- overridden: Hyprland registers duplicate keybinds additively, so leaving them
-- in would make SUPER + Q both open a terminal and close the focused window.


--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/
-- and https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/

-- Example window rules that are useful

hl.window_rule({
    -- Ignore maximize requests from all apps.
    name  = "suppress-maximize-events",
    match = { class = ".*" },

    suppress_event = "maximize",
})

hl.window_rule({
    -- Fix some dragging issues with XWayland
    name  = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },

    no_focus = true,
})

-- Hyprland-run windowrule
hl.window_rule({
    name  = "move-hyprland-run",
    match = { class = "hyprland-run" },

    move  = "20 monitor_h-120",
    float = true,
})


-----------------------------------
---- OMARCHY 4.0 (cherry-picked) ----
-----------------------------------

-- Loaded last so these override the stock values above.
-- dofile with an absolute path avoids depending on package.path.
-- Manage the theme with: omarchy-theme <name>
local hypr = os.getenv("HOME") .. "/.config/hypr/"

dofile(hypr .. "omarchy-looknfeel.lua")
dofile(hypr .. "omarchy-windows.lua")
dofile(hypr .. "omarchy-qconsole.lua")
dofile(hypr .. "omarchy-bindings.lua")

-- theme.lua is generated by `omarchy-theme <name>`, so it does not exist yet on
-- a fresh checkout. dofile on a missing file raises and takes the whole config
-- down with it -- which locks you out of the session. Load it only if present.
local theme = hypr .. "theme.lua"
local fh = io.open(theme)
if fh then
  fh:close()
  dofile(theme)
end
