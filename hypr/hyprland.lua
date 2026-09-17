-- Hyprland entry point. Reference: https://wiki.hypr.land/Configuring/Start/
--
-- This file wires the config together and holds only what has nowhere better
-- to live: monitors, environment, input, animation curves. Machine-specific
-- values come from profile.lua; behaviour lives in modules/.
--
-- Stock settings that a module overrides have been deleted rather than left
-- here commented out -- a duplicate that loses is just a lie about what is in
-- effect.
--
-- Load order matters and is the mechanism, not an accident:
--   * hl.config() merges, so a later module wins per key.
--   * Named window rules replace by name, so redeclaring a rule's name updates
--     it in place -- keeping its original position in the ordering.
--   * hl.bind is ADDITIVE and there is no hl.unbind. A second bind on a key
--     does not replace the first, it fires as well. Every keybind therefore
--     has exactly one owner: modules/bindings.lua.

local hypr = os.getenv("HOME") .. "/.config/hypr/"

-- Global on purpose. Every module reads it, and assigning it here -- before a
-- single module loads -- keeps the dependency visible at the top of the file
-- rather than hidden in a require graph.
jpu = dofile(hypr .. "profile.lua")


------------------
---- MONITORS ----
------------------

-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
-- Catch-all first, so an unplanned display (a TV, a projector) still lights up
-- at something sane instead of not at all.
hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = "auto",
})

hl.monitor(jpu.monitor)


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

-- Qt/KDE apps (Dolphin, Ark, Okular) need the KDE platform theme named
-- explicitly. Qt picks its theme plugin from XDG_CURRENT_DESKTOP, which is
-- "Hyprland" here, so KDEPlasmaPlatformTheme6.so never loads and the app
-- palette comes from the xdg-desktop-portal fallback instead of kdeglobals.
-- The visible symptom is Dolphin drawing black label text on its dark
-- background, which "fixes itself" only until the next launch when you pick a
-- colour scheme by hand in its own settings. Needs the plasma-integration
-- package; harmless if no Qt app is installed.
hl.env("QT_QPA_PLATFORMTHEME", "kde")


-----------------------
---- LOOK AND FEEL ----
-----------------------

-- Gaps, borders, rounding, shadow and blur are all set by modules/looknfeel.
-- Border colors come from theme.lua. Only the animation master switch is left
-- here, because nothing downstream sets it.
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

-- dwindle and master are configured in modules/looknfeel. This one is not.
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
        -- modules/looknfeel disables the logo outright; this only governs
        -- which stock wallpaper would be used if one ever were.
        force_default_wallpaper = -1,

        -- Both default to false, which makes a DPMS-blanked screen look like a
        -- dead machine: hypridle's on-resume is then the *only* thing that can
        -- bring the display back, so if it is misconfigured or not running you
        -- are left hammering a keyboard at a black monitor.
        key_press_enables_dpms  = true,
        mouse_move_enables_dpms = true,
    },
})


---------------
---- INPUT ----
---------------

hl.config({
    input = {
        kb_layout  = jpu.keyboard_layout,
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


--------------------------------
---- BASELINE WINDOW RULES ----
--------------------------------

-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/
-- Hyprland's own sane defaults. Everything opinionated is in modules/windows.

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

hl.window_rule({
    name  = "move-hyprland-run",
    match = { class = "hyprland-run" },

    move  = "20 monitor_h-120",
    float = true,
})


-----------------
---- MODULES ----
-----------------

-- Loaded last so these override the baseline above. dofile with an absolute
-- path avoids depending on package.path.
local modules = hypr .. "modules/"

dofile(modules .. "looknfeel.lua")
dofile(modules .. "windows.lua")
dofile(modules .. "autostart.lua")
dofile(modules .. "qconsole.lua")
dofile(modules .. "bindings.lua")

-- theme.lua is generated by `omarchy-theme <name>` and gitignored, so it does
-- not exist on a fresh clone. dofile on a missing file raises and takes the
-- whole config down with it -- which locks you out of the session. Load it
-- only if present.
local theme = hypr .. "theme.lua"
local fh = io.open(theme)
if fh then
  fh:close()
  dofile(theme)
end
