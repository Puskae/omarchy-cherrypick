-- Omarchy 4.0 look & feel, cherry-picked onto stock Hyprland.
-- Pure hl.* API -- no Omarchy runtime or helper scripts required.
-- Source: omarchy default/hypr/looknfeel.lua

hl.config({
  general = {
    -- Omarchy runs tighter than the stock 20.
    gaps_in  = 5,
    gaps_out = 10,
    border_size = 2,

    -- Grab a window edge with the pointer to resize it. Omarchy ships this
    -- off, which leaves SUPER + right-drag as the only way to resize with a
    -- mouse -- fine when the other hand is on the keyboard, useless when it
    -- is not. extend_border_grab_area (15, stock) makes the 2px border a
    -- 15px target, and hover_icon_on_border (also stock) changes the cursor
    -- so the target is visible. The cost is that the grab zone lives inside
    -- the gap, so a click aimed at the very edge of a window resizes instead
    -- of focusing.
    resize_on_border = true,
    allow_tearing    = false,
    layout = "dwindle",
  },

  decoration = {
    -- Omarchy is deliberately flat: square corners, no shadow, no blur.
    rounding = 0,
    shadow = { enabled = false },
    blur   = { enabled = false },
  },

  group = {
    groupbar = {
      font_size          = 12,
      font_family        = "monospace",
      font_weight_active = "ultraheavy",
      font_weight_inactive = "normal",
      indicator_height   = 1,
      indicator_gap      = 5,
      height             = 22,
      gaps_in            = 5,
      gaps_out           = 0,
      text_color          = "rgb(ffffff)",
      text_color_inactive = "rgba(ffffff90)",
      col = {
        active   = "rgba(00000040)",
        inactive = "rgba(00000020)",
      },
      gradients = true,
      gradient_rounding = 0,
      gradient_round_only_edges = false,
    },
  },
})

-- Omarchy drives windows off easeOutQuint rather than the stock spring,
-- and turns workspace-switch animation off entirely.
hl.animation({ leaf = "windows",    enabled = true,  speed = 3.79, bezier = "easeOutQuint" })
hl.animation({ leaf = "windowsIn",  enabled = true,  speed = 4.1,  bezier = "easeOutQuint", style = "popin 87%" })
hl.animation({ leaf = "fadeSwitch", enabled = false })
hl.animation({ leaf = "workspaces", enabled = false })

hl.config({
  dwindle = {
    preserve_split = true,
    force_split    = 2,
  },

  master   = { new_status = "master" },
  scrolling = { column_width = 0.49 },

  misc = {
    disable_hyprland_logo      = true,
    disable_splash_rendering   = true,
    disable_scale_notification = true,
    focus_on_activate          = true,
    anr_missed_pings           = 3,
    on_focus_under_fullscreen  = 1,
    initial_workspace_tracking = 0,

    -- Variable refresh rate depends on the panel, not on taste, so the value
    -- lives in profile.lua.
    vrr                        = jpu.vrr,
  },

  cursor = {
    hide_on_key_press       = true,
    warp_on_change_workspace = 1,

    -- Don't teleport the pointer onto whatever just took focus. Hyprland warps
    -- by default, so a window that activates itself -- a Firefox PiP retitling
    -- when the video changes, say -- drags the mouse across the ultrawide with
    -- it. Workspace switches still warp; that one is wanted.
    no_warps                = true,
  },

  binds = {
    hide_special_on_workspace_change = true,
  },
})
