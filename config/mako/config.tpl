# mako notifications, themed from the Omarchy palette.
#
# Rendered by `omarchy-theme <name>` into `config` beside this file -- edit
# config.tpl, never config. Omarchy 4.0 has no mako template of its own (its
# notifications are a Quickshell component), so this is this repo's own,
# matched to the same palette as waybar and walker.
#
# The double-brace slots below are keys from the theme's colors.toml; only
# the six that every Omarchy theme defines are used.
#
# Note that mako has no config include that can be missing safely: a bad or
# absent include kills the whole config and mako then refuses to start, which
# reads as "notifications are gone". Hence one generated file, no includes.

font=MesloLGM Nerd Font 10

background-color={{ background }}
text-color={{ foreground }}
border-color={{ accent }}
progress-color=over {{ selection }}

border-size=1
border-radius=0
width=380
height=160
margin=10
padding=10,14

anchor=top-right

# top, not overlay: notifications stay under a fullscreen window rather than
# painting over a game.
layer=top

max-visible=5
max-history=20

icons=1
markup=1
actions=1

# Auto-dismiss after 5s. mako's own default is 0 -- no expiry at all -- which
# is why anything sent by plain notify-send (bin/llm-vram-release,
# bin/hypr-record) used to sit in the corner until dismissed by hand.
default-timeout=5000

# Left off deliberately: an application that asks for its own expiry still
# gets it, and only senders that ask for nothing fall back to the 5s above.
ignore-timeout=0

# Urgent notifications are exempt -- they stay until acknowledged.
[urgency=critical]
border-color={{ red }}
default-timeout=0

[urgency=low]
text-color={{ muted }}

# SUPER + CTRL + comma toggles this mode (omarchy-bindings.lua). Without a
# section defining it, that bind toggles a mode that does nothing at all.
[mode=do-not-disturb]
invisible=1
