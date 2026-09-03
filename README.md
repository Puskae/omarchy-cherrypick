# omarchy-cherrypick

Cherry-pick [Omarchy](https://omarchy.org) 4.0's Hyprland configs and themes onto an
existing **CachyOS** install — **without installing the Omarchy runtime**, on **AMD**
hardware.

**This is not the full Omarchy experience, and isn't trying to be.** Omarchy is a
whole opinionated system: its installer, the `omarchy-*` menus and helpers, its
update path, its defaults across dozens of apps. Almost none of that is here, and
none of it is reimplemented. **If you want Omarchy, [install the real
thing](https://omarchy.org)** — it's the better answer, and this is no substitute
for it.

What this *is*: a quick way to try Omarchy's Hyprland configuration and its themes
on CachyOS without committing to anything, and **without disturbing the Wayland
session you already have.**

Nothing here replaces your distro. CachyOS keeps its kernel, its repos, its defaults,
and its Plasma session. Hyprland becomes a second session you can log into, and log
back out of when it breaks.

**If you are not comfortable learning hotkeys, don't bother with Hyprland.** This
is not a preference or a difficulty badge — it is how the thing is operated. There
is no menu, no taskbar to click a window back out of, no drag-to-arrange. Launching
an app, closing one, moving between workspaces, resizing a tile: each is a key
combination and nothing else, and there are over a hundred of them in this config
alone. `SUPER + K` prints the full list, and the first week is spent with it open.
If that sounds like the appeal, you will get on well here. If it sounds like a
chore you would rather not have, Plasma is genuinely the better desktop for you and
staying on it costs you nothing.

> [!WARNING]
> **If you already have a working Hyprland, back it up before you copy anything.**
> These files are a complete config set, not an overlay: they replace
> `hyprland.lua` and every module beside it, and the keybindings, window rules,
> gaps, animations and autostart list are all Omarchy's rather than yours. Dropping
> them onto an existing setup does not merge with it, it overrides it — and the
> Finnish keysyms and `DP-3` monitor block below mean the result may not even be
> usable until you edit it. `cp -r ~/.config/hypr ~/.config/hypr.bak` first; the
> [step 3](#3-configs) snippet does exactly that, but do it now if you are only
> skimming.
>
> **Once you're in Hyprland, configure it from the `.lua` files — not from a settings
> GUI.** Plasma's System Settings writes to Plasma's own config (`kwinrc`,
> `kdeglobals`, kscreen's saved monitor layouts), and Hyprland reads none of it. Change
> your monitor arrangement, keyboard layout, input behaviour or window appearance there
> and it will look like it worked, apply to your Plasma session only, and do nothing in
> Hyprland — or leave the two sessions disagreeing about your displays. The same goes
> for any other desktop's control panel, and for appearance: themes come from
> `omarchy-theme <name>`, not from Plasma's Appearance page.
>
> In the Hyprland session, `~/.config/hypr/*.lua` is the only source of truth. Edit it,
> then `hyprctl reload`.

> **Not affiliated with, endorsed by, or a distribution of Omarchy.**
> Omarchy is a pending trademark of the Omacom Foundation. This repo cherry-picks
> Omarchy's MIT-licensed configuration (Copyright © David Heinemeier Hansson) and is
> an independent set of adaptations and notes.

**[→ See what the themes look like](https://omarchy.org/manual/themes/)** — Omarchy's own
gallery. No theme files, wallpapers or screenshots of them are stored here;
[step 2](#2-omarchys-themes-and-templates) installs them from Omarchy, and
`bin/omarchy-theme` then writes one theme's colors into your app configs.

---

## Why this exists

The existing option, [mroboff/omarchy-on-cachyos](https://github.com/mroboff/omarchy-on-cachyos),
patches and runs Omarchy's real installer. It's the right tool if you want all of
Omarchy. But it targets **Omarchy 3.0+**, predates the **4.0 Lua migration**, and its
one hardware special-case is pinning an **NVIDIA** driver.

This repo takes the opposite approach:

|                  | omarchy-on-cachyos      | omarchy-cherrypick            |
|------------------|-------------------------|-------------------------------|
| Omarchy version  | 3.0+                    | **4.0 (Lua)**                 |
| Runtime          | full install            | **none**                      |
| Config format    | `.conf` (hyprlang)      | **`.lua`**                    |
| GPU notes        | NVIDIA 580xx pin        | **AMD / amdgpu**              |
| Approach         | run the installer       | copy configs, keep your distro |

The tradeoff, restated: **you give up every `omarchy-*` CLI helper.** What you get
is a system where nothing was installed behind your back, and one Python script
replaces the single runtime feature actually worth keeping — theming.

## Does this actually need CachyOS?

Barely. Nothing in the configs calls a CachyOS tool — no `chwd`, no CachyOS kernel
feature, no `cachyos-*` package. What the install genuinely assumes is:

- **An Arch-family system with AUR access**, because the steps below are `pacman`
  and `paru`, and walker/elephant ship only in the AUR. **EndeavourOS**, Arch and
  Garuda qualify as they are. Manjaro does too, with the usual caveat that its
  held-back repos can lag what an AUR build expects.
- **Arch's packaging layout**, for exactly two absolute paths: hyprpolkitagent at
  `/usr/lib/hyprpolkitagent/hyprpolkitagent` in the autostart block, and elephant's
  providers in `/etc/xdg/elephant/providers/`. Both move on Fedora, openSUSE and
  Debian.
- **An existing desktop session to fall back into.** Mine is CachyOS's Plasma;
  anything works, as long as logging out of Hyprland lands you somewhere usable.

The parts that genuinely don't port are hardware, not distro: the AMD gamemode
hook, the QD-OLED VRR note, the `DP-3` monitor block and the Finnish keysyms. Those
need editing whatever you run.

So on **EndeavourOS** this should work unchanged, beyond the monitor and keyboard
edits you'd be making anyway. It says CachyOS because that's where it was built and
tested — not because it's coupled to it.

## What's here

```
bin/omarchy-theme        theme switcher; renders Omarchy's templates with no runtime
bin/llm-vram-release     frees GPU VRAM from Ollama before a game starts
bin/hypr-cheatsheet      keybinding cheatsheet in a terminal
bin/hypr-record          screen-recording toggle
bin/hypr-brightness      monitor brightness over DDC/CI (desktops have no backlight)
bin/hypr-tailscale       tailscale status as a waybar module
hypr/                    the Lua config set (hyprland.lua + 4 modules),
                         plus hypridle.conf and hyprlock.conf
config/waybar/           bar config + stylesheet + a fallback colors.css
config/walker/           launcher stylesheet template, rendered per theme
config/swaync/           notification centre config + stylesheet template
config/mako/             mako config template, kept as the lighter fallback
config/gamemode.ini      gamemode hooks
config/MangoHud.conf     hidden-by-default overlay (hyprland.lua sets MANGOHUD=1)
```

Not shipped, because `omarchy-theme` generates them per theme: `hypr/theme.lua`
and `hypr/hyprpaper.conf`.

`waybar/colors.css` *is* shipped even though it is generated, because
`style.css` `@import`s it and GTK throws away the whole stylesheet when an
`@import` cannot be resolved. The committed copy is a neutral grey placeholder
so that logging in before you have picked a theme gives you a styled bar rather
than an unstyled one and no clue why. The first `omarchy-theme <name>`
overwrites it.

`hypr-cheatsheet` decodes Hyprland's modmask bitfield with awk's `and()`, which is a
**gawk** extension. Nothing to install on an Arch-family system — gawk is a dependency
of both `base` and `pacman`, so it is always there — but the script prints nothing
useful under mawk or busybox awk if you take it somewhere else.

## What Omarchy has that this doesn't

Most of Omarchy is helper scripts. Anything in its config that is plain Hyprland
Lua has been brought over -- the window rules, the look and feel, the Quake
console, the layout toggles. Anything that shells out to an `omarchy-*` binary
could not be, because those binaries only exist inside an Omarchy install.

**Not here, and not coming** -- these are the runtime, not configuration:

- **`omarchy-menu`** -- the `SUPER + CTRL + <letter>` menus (capture, share,
  theme, background, hardware, system). `SUPER + SPACE` opens walker here instead.
- **`omarchy-shell`** -- Omarchy's Quickshell bar and its audio, bluetooth,
  network, clipboard and calendar panels. Waybar stands in for the bar, and
  [bar modules](#bar-modules-bluetooth-tailscale-brightness) cover bluetooth,
  tailscale and monitor brightness; the panels themselves have no equivalent.
- **The capture suite** -- screenshot menus, OCR text extraction, the webcam
  overlay, the recording menu. `grim`/`slurp`/`hyprpicker` and `bin/hypr-record`
  cover the common cases from the keyboard.
- **Reminders, weather and time notifications, transcode, the agent console,
  `omacalc`, the screensaver, voxtype and tensaku.**
- **`omarchy-update`** and the pacman hooks around it. Nothing here needs
  updating but the configs, and `git pull` does that.
- **Window helpers with saved state**: pop-out, save/restore width, tiled
  fullscreen, per-workspace layout memory, monitor scaling steps. These keep
  their state in files an `omarchy-*` script writes.

**Not here yet, but cheap to add** -- if you want them, they are a copy out of
`~/.local/share/omarchy/default/` after the clone in
[step 2](#2-omarchys-themes-and-templates):

- `envs.lua`'s Wayland block (`GDK_BACKEND`, `QT_QPA_PLATFORM`,
  `MOZ_ENABLE_WAYLAND`, `ELECTRON_OZONE_PLATFORM_HINT`, and
  `XDG_CURRENT_DESKTOP=Hyprland`, which is what makes screen sharing pick the
  right portal).
- `xcompose` -- emoji compose sequences, plus `kb_options = "compose:caps"`.
- `fontconfig/conf.avail/50-omarchy.conf` -- Omarchy's font substitutions.
- `firefox/policies.json` -- VAAPI hardware video decoding, worth having on AMD.
- `bindings/clipboard.lua` -- universal `SUPER + C/V/X` that emit the terminal's
  keys in a terminal and the usual ones everywhere else.

Everything else in that tree assumes the runtime. If a file mentions `o.bind`,
`o.window` or `require("default.hypr...")`, it will not load here as-is: those
are Omarchy's own helpers, and the rules have to be rewritten against the stock
`hl.bind` / `hl.window_rule` API the way the modules in `hypr/` are.

## Install

Assumes a working CachyOS install. Everything below is additive — your Plasma
session stays exactly as it is, and stays your way back in when Hyprland breaks.

### 1. Packages

From the repos:

```sh
sudo pacman -S --needed \
  hyprland hyprpaper hypridle hyprlock hyprpicker hyprpolkitagent \
  xdg-desktop-portal-hyprland qt6-wayland \
  waybar swaync alacritty ttf-meslo-nerd \
  grim slurp wl-clipboard playerctl pavucontrol \
  wlogout wf-recorder libnotify xdg-user-dirs
```

`libnotify` and `xdg-user-dirs` are usually already pulled in by Plasma; they're
listed because `bin/` uses `notify-send` and `xdg-user-dir` directly. `swaync` is
the notification daemon — add `mako` too if you'd rather run the
[lighter fallback](#notifications).
`ttf-meslo-nerd` supplies **MesloLGM Nerd Font**, which `hyprlock.conf` and the
waybar stylesheet both name — without it the lock screen clock and the bar's
glyphs fall back to whatever fontconfig picks, silently and badly.

Nothing here needs a cursor theme package: `hyprland.lua` sets
`XCURSOR_THEME=Adwaita`, and `adwaita-cursors` comes in with
`adwaita-icon-theme` → `gtk3` → `waybar`. Naming a theme matters — with only
`XCURSOR_SIZE` set, Hyprland has nothing to load and you get the tiny built-in
pointer, which looks like a broken session rather than a missing setting.
Point it at any theme under `/usr/share/icons` that has a `cursors/`
subdirectory.

From the AUR — **the launcher and every one of its providers**:

```sh
paru -S --needed \
  walker-bin elephant-bin \
  elephant-desktopapplications-bin elephant-runner-bin elephant-files-bin \
  elephant-menus-bin elephant-calc-bin elephant-clipboard-bin \
  elephant-symbols-bin elephant-websearch-bin elephant-providerlist-bin
```

**Don't trim the elephant list.** Each provider is a separate package dropping a
`.so` into `/etc/xdg/elephant/providers/`, and walker has no built-in fallback:
install the daemon without providers and you get a launcher that opens and finds
nothing. See [gotcha 4](#4-walkers-launcher-failure-looks-like-a-dead-keyboard).

Optional, if you want the gaming hooks or the apps the configs assume:

```sh
sudo pacman -S --needed gamemode gamescope mangohud   # gaming
sudo pacman -S --needed btop neovim                   # apps
sudo pacman -S --needed ddcutil                       # bar: monitor brightness
sudo pacman -S --needed tailscale                     # bar: tailscale status
sudo pacman -S --needed blueman                       # bar: bluetooth panel on click
```

The last three back optional bar modules — each one hides itself when its tool is
absent, so skipping them costs you nothing but the module. See
[Bar modules](#bar-modules-bluetooth-tailscale-brightness). Bluetooth itself is
built into waybar and needs only `bluez`/`bluez-utils`; `blueman` is just what the
click opens.

CachyOS already ships `wireplumber` (for `wpctl`), `networkmanager` (for `nmtui`,
which `SUPER + CTRL + W` and the bar's network module both open), `firefox` and —
with Plasma — `dolphin`. The configs reference all four, so they are not in the
list above; on a leaner Arch install that uses `iwd` or `systemd-networkd`
instead, either `pacman -S networkmanager` or point that bind and the module's
`on-click` somewhere else. The terminal, browser and file manager are declared at
the top of `hypr/omarchy-bindings.lua` — swap them there if you prefer others.

### 2. Omarchy's themes and templates

This repo ships the configs, **not** Omarchy's theme files — those are Omarchy's
to distribute. Grab them from the source:

```sh
git clone --depth 1 --branch v4.0.1 https://github.com/omacom/omarchy /tmp/omarchy
mkdir -p ~/.local/share/omarchy/default
cp -r /tmp/omarchy/themes          ~/.local/share/omarchy/themes
cp -r /tmp/omarchy/default/themed  ~/.local/share/omarchy/default/themed
rm -rf /tmp/omarchy
```

Both destinations are spelled out in full on purpose: `cp -r src dst/` *renames*
`src` to `dst` when `dst` does not exist yet, so the shorter form would drop the
templates at `default/*.tpl` instead of `default/themed/*.tpl`, and
`omarchy-theme` would then refuse to run. The clone is ~150 MB, almost all of it
the wallpapers.

**The `--branch v4.0.1` is not decoration.** Omarchy's default branch is
`quattro`, a development branch — clone it without a tag and you get whatever
was pushed that morning, which will eventually be Omarchy 5 rather than the 4.0
these configs were cherry-picked from. Nothing warns you: the palettes and
templates still render, just against a layout this repo has not been checked
against. Bump the tag deliberately, or not at all.

That is the entire dependency on upstream: a palette per theme, the wallpapers
each theme ships, and the `*.tpl` templates rendered against them. All 22 themes
come with that one clone — browse them at
[omarchy.org/manual/themes](https://omarchy.org/manual/themes/), then list what
landed locally with `omarchy-theme`.

### 3. Configs

> [!CAUTION]
> **These copies overwrite files by name.** If you already have a Hyprland,
> waybar, gamemode or MangoHud config, the matching file is replaced and the old
> one is gone. Back up first — the first command below does exactly that, and
> costs nothing if there was nothing to save.

> [!NOTE]
> **CachyOS's default shell is fish, and two snippets below are bash.** The backup
> loop here and the Alacritty heredoc further down both use syntax fish does not
> have (`for ... do ... done`, `<<'EOF'`), and fish reports them as a parse error
> rather than doing half the job. Both are wrapped in `bash -c` so they work in
> either shell — leave the wrapper in place if you are on fish, and it costs
> nothing if you are not. Everything else on this page is portable.

```sh
git clone https://github.com/Puskae/omarchy-cherrypick
cd omarchy-cherrypick

# Back up anything already there. Skips silently if these don't exist.
bash -c 'for d in hypr waybar MangoHud; do
  [ -e ~/.config/$d ] && cp -r ~/.config/$d ~/.config/$d.bak-$(date +%Y%m%d)
done
[ -e ~/.config/gamemode.ini ] && cp ~/.config/gamemode.ini ~/.config/gamemode.ini.bak'

# The directories may not exist yet -- Hyprland has never run here.
mkdir -p ~/.config/hypr ~/.config/waybar ~/.config/MangoHud ~/.local/bin

cp hypr/*              ~/.config/hypr/
cp config/waybar/*     ~/.config/waybar/
mkdir -p ~/.config/walker/themes/omarchy ~/.config/swaync ~/.config/mako
cp config/walker/style.css.tpl ~/.config/walker/themes/omarchy/
cp config/swaync/*             ~/.config/swaync/
cp config/mako/config.tpl      ~/.config/mako/
cp config/MangoHud.conf ~/.config/MangoHud/
cp config/gamemode.ini ~/.config/
cp bin/*               ~/.local/bin/

# gamemode expands neither ~ nor $HOME in a hook, so the path must be absolute.
# The shipped file says /home/yourusername; this puts your own path in.
sed -i "s|/home/yourusername|$HOME|" ~/.config/gamemode.ini

# git preserves the exec bit, so this is only needed if you copied by hand.
chmod +x ~/.local/bin/omarchy-theme ~/.local/bin/llm-vram-release \
         ~/.local/bin/hypr-cheatsheet ~/.local/bin/hypr-record \
         ~/.local/bin/hypr-brightness ~/.local/bin/hypr-tailscale

omarchy-theme                 # list themes
omarchy-theme nord            # apply one
```

**Alacritty needs one line to actually use the theme.** `omarchy-theme` writes
`~/.config/alacritty/omarchy-theme.toml`, but it will not touch
`alacritty.toml` — that file is yours. Nothing imports the generated colors
until you say so, so add:

```sh
mkdir -p ~/.config/alacritty
bash -c 'cat >> ~/.config/alacritty/alacritty.toml <<"EOF"

[general]
import = ["~/.config/alacritty/omarchy-theme.toml"]
live_config_reload = true
EOF'
```

(If you already have a `[general]` table, put the two keys in it instead of
appending a second one — TOML rejects a duplicate table.) `omarchy-theme`
prints this reminder whenever the import line is missing.

`~/.local/bin` has to be on your `PATH` for `omarchy-theme` to be callable by
name; on CachyOS's default fish and on Arch's bash it already is.

**`MangoHud.conf` is not optional here.** `hyprland.lua` sets `MANGOHUD=1`
globally, which is only pleasant because that config sets `no_display` — the
overlay stays hidden until `Shift_R + F12`. Without the file you get an FPS
counter stapled to every OpenGL and Vulkan app you own, Firefox included. If you
don't want any of that, delete the `hl.env("MANGOHUD", "1")` line instead.

**Edit `hypr/hyprland.lua` before using it.** `input.kb_layout` is `fi`, which is
the one edit you cannot skip. The monitor block hardcodes a 3440x1440@164.90
ultrawide on `DP-3`, but that one is safe to leave: a catch-all `hl.monitor` with
`output = ""` sits above it, so an unknown display still comes up at its preferred
mode and only your own monitor's name and refresh rate are worth filling in.

**On a non-Finnish layout, three binds are dead until you rename them.** The
resize and scratchpad binds in `hypr/omarchy-bindings.lua` name Finnish keysyms,
and a keysym your layout does not produce registers fine and never fires — see
[gotcha 2](#2-hlbind-has-no-keycode-support--and-fails-silently). They are the
same physical keys either way, so on a US layout substitute:

| In the config | US layout | Physical key | Used by |
|---|---|---|---|
| `plus`       | `minus` | `-` | resize: shrink |
| `dead_acute` | `equal` | `=` | resize: grow |
| `section`    | `grave` | `` ` `` | scratchpad toggle |

```sh
sed -i 's/\.\. "plus"/.. "minus"/g; s/\.\. "dead_acute"/.. "equal"/g; s/SUPER + section/SUPER + grave/' \
  ~/.config/hypr/omarchy-bindings.lua
```

For any other layout, run
`wev` (or `xkbcli interactive-wayland`) and press the key to see the keysym it
actually emits.

**And `config/gamemode.ini`** ships a placeholder path,
`/home/yourusername/.local/bin/llm-vram-release`: gamemode expands neither `~` nor
`$HOME` in a hook, so that path has to be absolute. The `sed` line above rewrites
it; if you copied the file by hand instead, put your own username in it, or the
hook silently never runs.

### 4. Log in

Log out, and pick **Hyprland** at your display manager. If it drops you straight
back to the login screen, pick Plasma again and read the log:

```sh
cat "$XDG_RUNTIME_DIR"/hypr/*/hyprland.log
```

A Lua syntax error takes the whole config down, and names the file and line that
broke. (The log lives under `$XDG_RUNTIME_DIR`, so it is wiped on logout — read it
from the Plasma session you fell back into, in the same boot.)

---

## The six things that cost me a day

This is the part worth reading. Every one of these presents as a different problem
than it is.

### 1. Omarchy 4.0 is Lua. Almost every guide online is not.

Omarchy 4.0 converted its Hyprland configs from hyprlang (`*.conf`) to Hyprland's
Lua format for 0.56 compatibility, and expanded theme colors from 8 to 24 so
btop/nvim/vscode themes can be autogenerated.

Practically: **most Hyprland documentation, blog posts and StackExchange answers show
`.conf` syntax that will not work.** You want `hl.config{}`, `hl.bind{}`,
`hl.monitor{}`, `hl.env()`, `hl.exec_cmd()`, `hl.on("hyprland.start", ...)`.

Because it's Lua, it's a real program — modules load with `dofile` and an absolute
path, which avoids depending on `package.path`.

### 2. `hl.bind` has no keycode support — and fails silently

Omarchy binds workspace and resize keys **by keycode** (`code:20`, etc.). In this
setup that form is **accepted and never fires.** No error, no warning, no log line.
The bind simply does nothing.

Use keysyms for your layout instead. Expect to lose an hour to this if you don't
know it, because a silently-dead bind looks like a broken keyboard, not a config bug.

### 3. Not using uwsm breaks every systemd user unit

The session runs plain `start-hyprland`, **not** uwsm. Consequence: nothing ever
activates `graphical-session.target`, so **every user unit that is `WantedBy=` it
never starts.** hyprpaper even `Requires=` it.

That's why the autostart block launches daemons **directly**:

```lua
hl.on("hyprland.start", function()
  hl.exec_cmd("systemctl --user import-environment $(env | cut -d'=' -f 1)")
  hl.exec_cmd("dbus-update-activation-environment --systemd --all")
  hl.exec_cmd("/usr/lib/hyprpolkitagent/hyprpolkitagent")
  hl.exec_cmd("hyprpaper")
  hl.exec_cmd("swaync")
  hl.exec_cmd("waybar")
  hl.exec_cmd("hypridle")
  ...
end)
```

Don't "fix" this by converting them to `systemctl --user start` unless you move the
session to uwsm. The symptom of getting it wrong is subtle: things work, but only
sometimes, depending on what else happened to activate the target.

### 4. Walker's launcher failure looks like a dead keyboard

[Walker](https://github.com/abenz1267/walker) needs the **elephant** daemon. Two traps:

- **elephant ships no systemd unit.** Omarchy writes one during an install that never
  ran here. So nothing starts it.
- **Providers are separate packages**, dropping `.so` files into
  `/etc/xdg/elephant/providers/`: `elephant-desktopapplications-bin`, `-calc-`,
  `-clipboard-`, `-files-`, `-menus-`, `-runner-`, `-symbols-`, `-websearch-`,
  `-providerlist-`.

Without the daemon, walker maps its overlay and waits on *"waiting for elephant"*
forever **while holding keyboard focus.** You don't see a launcher error. You see a
desktop that stopped responding to the keyboard. I spent a long time debugging the
wrong subsystem.

An **empty walker with no results means no providers are installed** — not a broken
walker.

Both start from the autostart block:

```lua
hl.exec_cmd("elephant")
hl.exec_cmd("walker --gapplication-service")
```

### 5. hyprpaper 0.8 changed its config format, and fails silently

This one cost the most, because **there is no error message anywhere.**

hyprpaper 0.8 replaced the flat config keys with a section block. The old syntax
— the one in every guide and in Omarchy's own generated config — still parses
without complaint and then quietly creates no wallpaper:

```ini
# Silently does nothing on 0.8.x
preload   = /path/to/image.jpg
wallpaper = ,/path/to/image.jpg
```

```ini
# Correct
wallpaper {
    monitor =
    path = /path/to/image.jpg
}
splash = false
ipc = on
```

The only hint is in hyprpaper's own stdout, which you never see because it's
started in the background:

```console
$ hyprpaper
Monitor DP-3 has no target: no wp will be created
```

`hyprctl hyprpaper listactive` returning **empty** while hyprpaper is running is
the fast way to confirm it.

The IPC verbs changed in the same release: **`preload`, `listloaded` and `unload`
are gone.** Only `wallpaper` and `listactive` remain, and `wallpaper` auto-loads:

```sh
hyprctl hyprpaper wallpaper ",/path/to/image.jpg"   # leading , = all monitors
```

Requires `ipc = on`. No restart needed.

Note the trap this combination sets: setting a wallpaper over IPC works fine, so
the desktop looks correct — right up until you reboot and the config, which never
worked, is all that's left.

**For a plain black background, don't use a black image.** Drop hyprpaper entirely
and set `misc.background_color` in `hyprland.lua` — Hyprland's default is
`0xff111111`, which is near-black but not black.

### 6. Every `hyprctl dispatch` in an *external* config is a Lua syntax error

Gotcha 1 says Omarchy 4.0's configs are Lua. The part that bites later is that
**`hyprctl dispatch` parses its argument as Lua too** — so every other program's
config file that shells out to `hyprctl` is holding a pre-Lua string that Hyprland
0.56 now rejects:

```console
$ hyprctl dispatch dpms off
error: [string "return hl.dispatch(dpms off)"]:1: ')' expected near 'off'

$ hyprctl dispatch 'hl.dsp.dpms({ mode = "off" })'
ok
```

These live outside the `.lua` files, so converting the Hyprland config doesn't
touch them. In this repo it was `hypridle.conf` (three lines) and waybar's power
button. **The symptom is that the screen never sleeps** — hypridle checks no exit
code and prints nothing, so a dead `on-timeout` is indistinguishable from an idle
timer that simply isn't firing. I went looking at power management first.

Grep your whole config tree for `hyprctl dispatch` after migrating, not just
`~/.config/hypr`.

Two things make this worse than it needs to be:

- **`hyprctl dispatch` validates nothing.** A dispatcher that takes a table
  accepts a wrong key silently — `hl.dsp.dpms({ state = "off" })` returns `ok`
  and does nothing. Confirm the effect, not the exit code:
  `hyprctl monitors -j | grep dpmsStatus`.
- **`misc:key_press_enables_dpms` and `misc:mouse_move_enables_dpms` both default
  to `false`.** Once DPMS does start working, hypridle's `on-resume` becomes the
  only thing that can wake the display — so a second mistake leaves you pressing
  keys at a black monitor with a machine that is fine. Omarchy sets both `true`;
  `hyprland.lua` here does too.

## Bar modules: bluetooth, tailscale, brightness

Omarchy's bar carries panels for these; those are Quickshell components and are
not here. Waybar covers the same ground with three modules, and **each one hides
itself when its backing tool is missing**, so none of them is a hard dependency.

A fourth, `custom/notification`, is documented with the daemon it belongs to
under [Notifications](#notifications).

There is also a **launcher button** at the far left, where Omarchy puts the one
that opens its menu. It is a `custom/menu` module and it opens walker — the same
thing `SUPER + SPACE` does, and walker's own `close_when_open` makes a second
click dismiss it. The glyph is a generic apps grid, not Omarchy's logo: this repo
is not affiliated with Omarchy and should not ship its mark. Swap it for anything
your Nerd Font has.

**Bluetooth** is built into waybar — it speaks to bluez over D-Bus, so `bluez`
and `bluez-utils` (already needed for the adapter) are the whole requirement. It
shows the connected device count and enumerates paired devices in the tooltip.
Clicking wants a GUI: `blueman-manager` if you have it, otherwise `bluetoothctl`
in a terminal. `blueman` is deliberately not in the package list.

**Tailscale** (`bin/hypr-tailscale`) reports state, your tailnet IP, how many
peers are online, and the exit node if one is in use. Clicking lists the peers in
a terminal. It is **read-only on purpose**: `tailscale up` and `down` need root
unless an operator is set, and a bar button that pops a password prompt on a
stray click is worse than one that just tells you the truth. If you want it to
toggle, run `sudo tailscale set --operator=$USER` first and wire the action up
yourself.

**Brightness** (`bin/hypr-brightness`) is the interesting one on a desktop.
There is no `/sys/class/backlight` — the panel is on the far end of a
DisplayPort cable — so `brightnessctl` has nothing to talk to. The control lives
on the monitor's I2C side channel, DDC/CI, and `ddcutil` drives it (VCP code
`0x10`). Needs the `ddcutil` package and the `i2c-dev` module; **no root**,
because logind puts an ACL on `/dev/i2c-*` for the active seat. If it does not
work, look for the `+` marking that ACL in `ls -l /dev/i2c-*`, and otherwise add
yourself to the `i2c` group.

DDC is slow — about **1s** for a read, **0.4s** for a write, and that is the wire,
not ddcutil. Polling it in the bar would be absurd, so the value is cached in
`$XDG_RUNTIME_DIR` and the module is read `"once"`, then refreshed only when the
script signals it (`SIGRTMIN+8`). Scroll over the module to change brightness;
click to re-read from the monitor if you have used its own buttons.

**The script is more than a `setvcp` wrapper, and the reason is worth knowing if
you write your own.** A scroll fires a keypress per tick, so the naive version
starts a process per tick, each wanting half a second on a bus that admits one
user at a time. They collide, ddcutil fails its *own* flock, and — this is the
part that bites — it prints the diagnostic **on stdout**, where a bar module
happily renders it. The symptom is a sluggish wheel and then `wait%` in the bar,
because "wait" is the first word of `wait for diagnostics: locking call ...`.

So the script splits the two concerns. The cached value is the *wanted* value,
updated instantly under a short lock with waybar signalled immediately, so the
number tracks the wheel and never waits on I2C. A separate single writer holds a
`flock` and re-reads the wanted value after each write, collapsing twenty ticks
into the two or three the bus can absorb while still finishing on the last one;
any invocation that finds the lock taken returns at once (~20ms) rather than
queueing. Every value is checked against `^[0-9]{1,3}$` and `<= 100` before it is
cached, so a diagnostic can never reach the bar again.

**There is a floor at 5%, and every path goes through it.** A monitor at 0 is a
black screen, and you cannot see well enough to undo it — DDC gives no feedback
that would even tell you the panel is still on, so it reads as a dead display.
`clamp()` is the one place any value passes through, which matters because there
are five callers: the keybinds, the bar's scroll, swaync's brightness buttons,
`config/gamemode.ini`, and the shell. A floor only some of them respect is not a
floor. Raise or drop it with `FLOOR` at the top of the script. Note it is
deliberately *not* a `min_limit` on the widget side: swaync's slider clamps by
calling `set_value()` from inside its own `value_changed` handler, which resets
the drag gesture mid-drag and leaves the handle stuck — so widgets get the full
0–100 range and the script refuses the dark end.

Not every monitor answers DDC/CI, and some need it enabled in their OSD first.
`ddcutil detect` is the test — if it finds nothing, the module simply does not
appear.

**If a module is blank rather than absent**, check that `~/.local/bin` is on the
`PATH` the session gives waybar — it runs `hypr-brightness` and `hypr-tailscale`
by name, and a display manager does not always source the profile that adds that
directory. `tr '\0' '\n' < /proc/$(pgrep -x waybar)/environ | grep ^PATH` answers
it. Failing that, put absolute paths in the module's `exec`.

---

## Theming without the runtime

`bin/omarchy-theme` is the piece with no equivalent elsewhere. Every other Omarchy
theme tool calls `omarchy-theme-set`, which requires the runtime.

An Omarchy theme is just `themes/<name>/colors.toml` — about 25 flat hex values.
`default/themed/*.tpl` are templates with `{{ variable }}` slots. Applying a theme
means rendering templates against one palette. That's the whole mechanism, and the
core of it is about fifty lines. The script is ~380 because the rest is per-app skip
guards, palette fallbacks for keys not every theme defines, and reloading each app
in place afterwards.

This script renders **eleven** outputs:

| Output | Path | Notes |
|---|---|---|
| Alacritty colors | `~/.config/alacritty/omarchy-theme.toml` | `import` it from `alacritty.toml`; live reload |
| Hyprland borders | `~/.config/hypr/theme.lua` | `hyprctl reload` |
| Waybar colors    | `~/.config/waybar/colors.css` | `@import`ed by the shipped `style.css`; `pkill -USR2 waybar` |
| Wallpaper        | `~/.config/hypr/hyprpaper.conf` | hyprpaper restarted |
| btop             | `~/.config/btop/themes/omarchy.theme` | restart btop |
| Neovim           | `~/.config/nvim/lua/plugins/omarchy-theme.lua` | LazyVim only |
| kitty            | `~/.config/kitty/omarchy-theme.conf` | `include` it yourself |
| foot             | `~/.config/foot/omarchy-theme.ini` | `include` it yourself |
| walker           | `~/.config/walker/themes/omarchy/style.css` | walker restarted |
| swaync           | `~/.config/swaync/style.css` | `swaync-client --reload-css` |
| mako             | `~/.config/mako/config` | `makoctl reload` |

Each app is **skipped unless its binary is on `PATH`**, so the script is safe on a
minimal system — and it does not skip a freshly installed app that has not created
its config directory yet. btop also gets its `color_theme` line rewritten to point at the generated
file. Neovim is skipped unless LazyVim is present, because both Neovim templates
emit a LazyVim plugin spec — without it you'd get a file nothing reads. 15 of the
22 themes ship a hand-picked colorscheme (nord uses nordfox); the rest fall back
to the palette-driven `aether` template.

**walker, swaync and mako are the outputs with no Omarchy template behind them.** Omarchy ships no
walker theme, because its launcher is a Quickshell component rather than walker
(see [What Omarchy has that this doesn't](#what-omarchy-has-that-this-doesnt)), so
`config/walker/style.css.tpl` is this repo's own — an interpretation of Omarchy's
flat, square look driven by the same six palette keys every theme defines. It is
installed *into* the generated theme directory and rendered to `style.css` beside
itself, so the template travels with the theme it produces.

Notifications are the same idea, and for the same reason — Omarchy's are a
Quickshell component too. The two daemons want opposite treatment, though:

- **swaync** loads `/etc/xdg/swaync/style.css` and *then* `~/.config/swaync/style.css`
  on top of it, so `config/swaync/style.css.tpl` only redefines the `:root` colour
  variables. The 500+ layout rules stay upstream's and track your installed
  version instead of a fork. Its `config.json` isn't generated at all — nothing in
  it is a colour, so it's copied in once at install and left alone.
- **mako** has no layering: `config/mako/config.tpl` renders the **whole** config.
  A colours-only fragment would have to be pulled in with mako's `include`, and a
  missing include is fatal — mako refuses to start on it, and a notification daemon
  that never came up looks like nothing at all rather than like an error.

A walker theme is layout XML plus a stylesheet. Only the stylesheet is generated;
the XML is copied once from the installed walker's own stock theme
(`/etc/xdg/walker/themes/default/`) rather than vendored here, so it tracks your
walker version instead of a pinned copy. `~/.config/walker/config.toml` gets its
`theme =` line pointed at `omarchy` — created from the system default first if you
have no config of your own, and otherwise left alone apart from that one line.

It then reloads each app in place — `hyprctl reload`, `pkill -USR2 waybar`, and a
hyprpaper restart (it only re-reads its config on start), plus
`swaync-client --reload-css` and `makoctl reload`, both of which re-read in place
without dropping notification history. Both are gated on the daemon actually
running, the same way the walker restart is — with mako installed as a fallback
while swaync is the one in use, an ungated `makoctl reload` would report a reload
that never happened on every single theme change. walker reads its theme at
startup too, so its `--gapplication-service` daemon is restarted — but only if one
was already running, so this never leaves a stray daemon on a machine that does not
autostart it. btop and Neovim have no reload signal, so those two are reported
rather than reloaded.

**Templates still dormant**: ghostty, helix, obsidian, vscode, chromium, shell and
more. Adding one is a few lines — read the template, render it, write it, reload
the app. PRs welcome.

Two behaviours to know:

- Applying a theme **silently replaces your wallpaper** with that theme's first
  background alphabetically. Hand-edits to `hyprpaper.conf` don't survive.
- Most themes ship pre-baked config of their own (`hyprland.lua`, `btop.theme`,
  `chromium.theme`, `vscode.json`). **This script ignores all of it** and renders
  the palette through Omarchy's templates instead — the one exception is Neovim,
  where a theme's own `neovim.lua` is preferred over the generic template. If you
  want a theme's hand-tuned btop colors rather than the generated ones, copy
  `themes/<name>/btop.theme` in yourself.

---

## Notifications

**swaync** (SwayNotificationCenter), autostarted from `hyprland.lua`, popups
anchored top-right. The reason it's swaync and not mako is the **control centre**:
`SUPER + N` slides out a panel listing everything that arrived, scrollable, with
each notification's own action buttons still live and a per-item dismiss. mako has
no surface of its own — only the popups — so with it, history can be read
(`makoctl history`) but not acted on.

### What's in the panel

swaync's control centre takes an ordered list of **widgets** in
`config/swaync/config.json` — that's its extension point, and 0.12.6 ships eleven
types. Six are enabled here, and three of them are doing real work rather than
decorating:

| Widget | Why |
|---|---|
| `notifications` | the list itself |
| `title`, `dnd` | header with Clear-all, and the DND switch |
| `mpris` | transport + album art — the bar's `custom/media` shows the track but can't control it |
| `volume` | sinks **plus per-app sliders**, which is most of what pavucontrol gets opened for |
| `inhibitors` | what is currently suppressing notifications, with a Clear button |

**Brightness is a `buttons-grid`, not a slider — and that is not a preference.**
Two of swaync's widgets could plausibly do it, and both are out:

- The **`backlight`** widget reads `/sys/class/backlight`, which a desktop does
  not have. That absence is the entire reason `bin/hypr-brightness` exists.
- The generic **`slider`** widget takes `cmd_getter`/`cmd_setter`, which looks
  like an exact fit — `hypr-brightness get` / `hypr-brightness set $value` — but
  **its drag gesture does not work.** Grab the handle and the value pins to the
  range minimum and never moves again; the handle still takes `:active` styling,
  so it looks alive.

The cause is in `slider.vala`, and it is worth knowing because the widget looks
fine on paper:

```vala
slider.value_changed.connect (() => {
    ...
    slider.set_value (value);   // ← writes back into the widget being dragged
```

It calls `set_value()` unconditionally from inside its own `value_changed`
handler, which cancels the in-flight GTK drag gesture. The `volume` widget's
handler never writes back — it only reads `slider.get_value ()` — which is why
that one drags perfectly under identical CSS. Verified on 0.12.6 by swapping the
setter for an instant log-only script (a whole drag produced exactly **one**
`value_changed`) and by stripping every custom CSS rule (no change). The file is
byte-identical on upstream `main`, so this is not fixed in a newer release.

So the panel gets five buttons instead — 20% / 50% / 80% presets and ±5% — each
calling `bin/hypr-brightness`, which needs no gesture and reuses the same
write-coalescing the bar module relies on. **If you have no DDC-capable monitor
or no `ddcutil`, drop the `buttons-grid#brightness` widget** (or use `backlight`
on a laptop, where it works).

Two theming traps here, both of which look like the widget is broken rather than
the stylesheet:

- swaync's own sheet styles `.per-app-volume` with `var(--noti-bg-alt)` and
  **never defines that variable**, so per-app rows render with no background at
  all. The template defines it.
- **Never set `min-width`/`min-height` on `scale slider`.** Adwaita gives the
  handle a negative margin, so a small min size computes negative — GTK warns
  `reported min height -6, but sizes must be >= 0` — and the handle ends up with
  no hit area. Size the `scale` instead and only colour the handle.

### Bar module

`custom/notification` in waybar is swaync's own recipe rather than a script of
this repo's: `swaync-client -swb` streams a JSON line on every add and close, so
the module is event-driven with no polling interval. The state name lands in the
CSS class, which is what colours the glyph:

| State | Glyph | Colour |
|---|---|---|
| nothing waiting | 󰂚 | `@fg` |
| notifications waiting | 󰂚 | `@accent` |
| do-not-disturb | 󰂛 | `@muted` |

The count is in the tooltip rather than the label — swaync sends `"0"` when
nothing is waiting, and a bar that permanently reads `0` is noise. Left-click
toggles the panel, right-click toggles DND, middle-click clears everything.

### Bindings

Every one of them passes `-sw` ("skip wait"): without it `swaync-client` blocks
waiting for a daemon that may not be running, so a bind hangs instead of failing.

| Bind | Action |
|---|---|
| `SUPER + N` | Toggle the notification centre |
| `SUPER + ,` | Dismiss the latest notification |
| `SUPER + SHIFT + ,` | Dismiss all |
| `SUPER + ALT + ,` | Invoke the latest notification's first action |
| `SUPER + CTRL + ,` | Toggle do-not-disturb |

### Timeouts

`timeout: 5`, `timeout-low: 5`, `timeout-critical: 0` — ordinary popups clear
themselves after 5s and critical ones stay until acknowledged. This only governs
the **popup**; everything lands in the control centre either way, which is the
practical difference from a plain daemon.

Popups sit on the `top` layer, not `overlay`, so they stay under a fullscreen
window rather than painting over a game. The control centre is `overlay` — you
only ever open it deliberately.

### Silence while gaming

`config/gamemode.ini` adds a named **inhibitor** when a game starts and removes it
when the game exits, so nothing pops up over a fullscreen game and everything is
still waiting in the panel afterwards:

```ini
start=/home/yourusername/.local/bin/llm-vram-release
    swaync-client -Ia gamemode -sw
end=swaync-client -Ir gamemode -sw
```

Two things make that work. gamemode runs `[custom]` hooks **through the shell**
and takes more than one command per hook as indented continuation lines — the
format is in the `[custom]` example in `gamemoded(8)`. And swaync's inhibitors are
**named**, so this can't desynchronise the way a do-not-disturb toggle would: the
end hook removes that exact inhibitor and leaves any other alone, and a game that
dies without running its end hook leaves one visible entry in the panel with a
Clear button rather than a silently muted desktop.

`end=` used to be `/bin/true` — there was nothing to undo, since Ollama reloads a
model on the next request by itself. Now it has a job.

Verify the whole thing without launching a game:

```sh
gamemoded -t
```

which runs both start scripts and the end script and reports each one.

### Falling back to mako

mako is still shipped, config and theme template both. It's a ~1 MB C daemon
against swaync's GTK4 one, and if the panel turns out to be something you never
open, it's the better trade. Swap one line in `hyprland.lua`:

```lua
hl.exec_cmd("mako")       -- instead of swaync
```

then `pacman -S mako`, `systemctl --user unmask mako.service` (see below),
re-point the four `comma` binds at `makoctl`
(`dismiss` / `dismiss --all` / `invoke` / `mode -t do-not-disturb`), drop the two
`swaync-client` lines from `config/gamemode.ini`, and drop the
`custom/notification` module from the bar — `makoctl` has no `-swb` equivalent, so
that module goes back to being a script you'd have to write.

One thing mako gets wrong by default, worth knowing if you do go back:
**`default-timeout` is `0` upstream**, meaning notifications never expire.
Anything from plain `notify-send` — including `bin/llm-vram-release` and
`bin/hypr-record` — then sits in the corner forever. `config/mako/config.tpl`
sets 5s, and defines the `[mode=do-not-disturb]` section that the DND bind
toggles; `makoctl mode -t` will happily toggle a mode no criteria section
defines, changing nothing at all.

#### Two daemons, one bus name

If you keep mako installed as a fallback rather than removing it, note that it is
still **D-Bus activatable**. Both daemons ship an activation file claiming
`org.freedesktop.Notifications`:

```console
$ grep -h Name= /usr/share/dbus-1/services/{fr.emersion.mako,org.erikreider.swaync}.service
Name=org.freedesktop.Notifications
Name=org.freedesktop.Notifications
```

So the first notification after login makes systemd try to activate mako while
swaync already owns the name, and the journal gets:

```
mako.service: Two services allocated for the same bus name
org.freedesktop.Notifications, refusing operation.
Activation request for 'org.freedesktop.Notifications' failed.
```

It is harmless — swaync keeps the name and the notification is delivered — but
it is noise, and it means "mako is kept as a one-line fallback" is not quite
true: the two race for the bus name. Silence it by masking the unit rather than
uninstalling mako, which keeps the binary and its themed config around:

```bash
systemctl --user mask mako.service
```

Both activation files carry `SystemdService=`, so activation routes through the
unit and masking is enough to stop it. The cost is that swapping back to mako is
now a two-step fallback — `systemctl --user unmask mako.service` as well as the
`hyprland.lua` line — which is why it is listed in the swap steps above.

---

## Gaming: Ollama and VRAM

Not Omarchy-related, but it belongs with an AMD desktop that also runs local models.

A 16 GB card cannot hold a resident LLM **and** a 3440x1440 game. When it runs out,
amdgpu resets the ring rather than failing gracefully — which presents as the GPU
locking up mid-game, not as an out-of-memory error.

Ollama keeps a model in VRAM for `OLLAMA_KEEP_ALIVE` (5 min default) after the last
request. `config/gamemode.ini` runs `bin/llm-vram-release` on game start, which
`ollama stop`s everything in `ollama ps`. There's no cleanup hook — the daemon
reloads on the next request by itself.

The same hook also silences notifications for the duration of the game — see
[Silence while gaming](#silence-while-gaming).

Governor and renice are deliberately **off** in that config: amd-pstate-epp already
boosts under `powersave`, and renice/softrealtime lack the privileges gamemode has
here. Both disabled keeps `gamemoded -t` clean. The hooks are the point, not the
scheduling.

### Discord over a fullscreen game

`SUPER + D` toggles a **special workspace** holding Discord. A special workspace draws
*over* the current one instead of switching away from it, so chat appears on top of a
fullscreen game and dismisses again — the game never leaves fullscreen and is never
told to redraw, which is the thing that makes alt-tabbing out of one go wrong.

Two pieces make it work, both already in the configs:

```lua
-- omarchy-windows.lua: Discord is captured on launch, silently
hl.window_rule({
  name  = "discord-overlay",
  match = { class = "discord" },
  workspace = "special:discord silent",
})

-- omarchy-bindings.lua
hl.bind("SUPER + D", hl.dsp.workspace.toggle_special("discord"), { description = "Discord overlay" })
```

`omarchy-qconsole.lua` sets `decoration:dim_special = 0.6`, which dims whatever
is underneath *any* special workspace — so a game darkens while the Discord
overlay is up. Set it to `0` in that file if you would rather it did not.

Discord is **not** in the package lists above — install it yourself (`discord`, or the
Flatpak) if you want this. Without it the bind is harmless: it toggles an empty
workspace. If you use a different client, or the Flatpak reports a different class,
check the real one with `hyprctl clients | grep class` and edit the rule — a `match`
that hits nothing fails silently, and you just get a plain window on your current
workspace.

---

## Known issue: clicking a workspace on the bar

On **waybar 0.15.0 + Hyprland 0.56**, clicking a workspace number in the bar does
nothing. The button is fine — waybar hardcodes the pre-Lua dispatcher string
`dispatch workspace <id>`, and Hyprland's Lua dispatcher rejects it:

```console
$ hyprctl dispatch workspace 2
error: [string "return hl.dispatch(workspace 2)"]:1: ')' expected near '2'
$ hyprctl dispatch 'hl.dsp.focus({ workspace = 2 })'
ok
```

The error goes back over IPC and is never surfaced, so the click looks ignored —
[gotcha 6](#6-every-hyprctl-dispatch-in-an-external-config-is-a-lua-syntax-error)
is the same root cause, except here the offending string is compiled into waybar
rather than sitting in a config file you can fix. Hyprland has no
legacy-dispatcher option, so nothing can be done from the Hyprland side either.

**Already fixed upstream, just not released.**
[Alexays/Waybar#5013](https://github.com/Alexays/Waybar/pull/5013) taught the
module Hyprland's Lua dispatch protocol; both reports
([#5008](https://github.com/Alexays/Waybar/issues/5008),
[#5147](https://github.com/Alexays/Waybar/issues/5147)) were closed on it in
July 2026. The newest waybar *release* is still 0.15.0 (February 2026), which
predates the fix — so on distro packages the symptom is live. Three ways to deal
with it, the last of which is a trap:

- **Install `waybar-git`** (AUR, or chaotic-aur) and clicks work today. Simplest
  real fix; the cost is tracking master.
- **Wait for the next waybar release**, and switch workspaces meanwhile with
  `SUPER+1..9` or by **scrolling over the bar** — that path works on 0.15.0,
  because the shipped `on-scroll-up`/`on-scroll-down` are config strings and so
  use the Lua form.
- **Don't** swap in `ext/workspaces`, the other workaround those threads
  suggest. It clicks fine, but the module has no special-workspace support —
  which silently breaks the Discord overlay above.

Config alone can't fix it: `hyprland/workspaces` has no per-button `on-click`
hook, and the sway-style `"on-click": "activate"` is not an option on this
module (waybar would run it as a shell command and swallow the built-in
handler). Drop this section once a fixed waybar release lands.

---

## Working on this

- Prefer editing the `.lua` files over the generated ones (`theme.lua`,
  `hyprpaper.conf`) — regenerating a theme overwrites them.
- Most Hyprland changes are live: `hyprctl reload`. Waybar needs `pkill -USR2 waybar`.
- **Test risky compositor changes from your Plasma session**, so a broken Hyprland
  config can't lock you out. This is the single most useful habit here.

## Credits

- [Omarchy](https://omarchy.org) by David Heinemeier Hansson — MIT
- [mroboff/omarchy-on-cachyos](https://github.com/mroboff/omarchy-on-cachyos) — the
  full-install approach, and prior art worth reading
- [CachyOS](https://cachyos.org)

## License

MIT — see [LICENSE](LICENSE). Cherry-picked Omarchy configuration remains
Copyright © David Heinemeier Hansson under MIT, and `hypr/hyprland.lua` began as
Hyprland's own example config, Copyright © vaxerski under BSD 3-Clause. Both
notices, the list of which files are derived from what, and the trademark note
live in [NOTICE](NOTICE) — which keeps `LICENSE` byte-for-byte standard so GitHub
detects it as MIT rather than "Other".
