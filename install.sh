#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# omarchy-cherrypick installer.
#
# Does what README section 3 does, in one pass, plus the package and theme
# steps from sections 1 and 2. It is a convenience, not a replacement for
# reading the README: three things still have to be edited by hand afterwards
# (keyboard layout, monitor, and the Finnish keysyms on a non-fi layout), and
# the script prints them at the end rather than guessing.
#
# Everything here is additive. Your Plasma session is untouched and stays your
# way back in when Hyprland breaks -- which is the actual safety net, not this
# script.
#
# Anything already in place is backed up before it is overwritten, and every
# path written is recorded in a manifest:
#
#     ~/.local/share/omarchy-cherrypick/manifest.tsv
#
# The manifest is what makes removal exact instead of guesswork. There is no
# uninstall script on purpose -- see "Removing it" in the README, which reads
# that file. A destructive script that runs once a year and is tested never is
# a worse trade than a documented list of paths.
#
# Usage:
#   ./install.sh [--dry-run] [--yes] [--no-packages] [--no-aur] [--no-themes]
#
#   --dry-run     print every action, change nothing
#   --yes         don't prompt (still honours the --no-* flags)
#   --no-packages skip pacman and paru entirely
#   --no-aur      pacman yes, AUR no (walker/elephant come from the AUR, so
#                 the launcher will not work until you install them)
#   --no-themes   skip the Omarchy theme clone (~150 MB); omarchy-theme has
#                 nothing to render until you do it
# ---------------------------------------------------------------------------

set -euo pipefail

REPO="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

STATE_DIR="$HOME/.local/share/omarchy-cherrypick"
MANIFEST="$STATE_DIR/manifest.tsv"
STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP_DIR="$STATE_DIR/backups/$STAMP"

OMARCHY_SHARE="$HOME/.local/share/omarchy"
OMARCHY_TAG="v4.0.1"
OMARCHY_REPO="https://github.com/omacom/omarchy"

DRY_RUN=0
ASSUME_YES=0
DO_PACKAGES=1
DO_AUR=1
DO_THEMES=1

# Straight from README section 1, plus `python`: omarchy-theme is
# #!/usr/bin/env python3 and nothing else in this list guarantees an
# interpreter on a minimal Arch install. Otherwise kept in the same order so
# the two can be diffed by eye when either changes.
PKGS_CORE=(
  hyprland hyprpaper hypridle hyprlock hyprpicker hyprpolkitagent
  xdg-desktop-portal-hyprland qt6-wayland
  waybar swaync alacritty ttf-meslo-nerd
  python
  grim slurp wl-clipboard playerctl pavucontrol
  wlogout wf-recorder libnotify xdg-user-dirs
)

# Every elephant provider is a separate package dropping a .so into
# /etc/xdg/elephant/providers/, and walker has no built-in fallback: the
# daemon without providers is a launcher that opens and finds nothing.
# Don't trim this list.
PKGS_AUR=(
  walker-bin elephant-bin
  elephant-desktopapplications-bin elephant-runner-bin elephant-files-bin
  elephant-menus-bin elephant-calc-bin elephant-clipboard-bin
  elephant-symbols-bin elephant-websearch-bin elephant-providerlist-bin
)

# Optional: each backs a feature that degrades quietly when absent. The bar
# modules hide themselves, and the gamemode hooks simply never fire.
PKGS_OPTIONAL=(
  gamemode gamescope mangohud
  btop neovim
  ddcutil tailscale blueman
)

# --- output ----------------------------------------------------------------

if [[ -t 1 ]]; then
  B=$'\e[1m'; DIM=$'\e[2m'; RED=$'\e[31m'; YEL=$'\e[33m'; GRN=$'\e[32m'; N=$'\e[0m'
else
  B=""; DIM=""; RED=""; YEL=""; GRN=""; N=""
fi

# Leaves nothing behind on any exit path: the rendered gamemode.ini, and the
# run's backup directory when it turned out to be empty (rmdir refuses a
# non-empty one, which is exactly the wanted behaviour).
cleanup() {
  rm -f "${GAMEMODE_TMP-}"
  [[ -n ${BACKUP_DIR-} ]] && rmdir "$BACKUP_DIR" 2>/dev/null
  return 0
}
trap cleanup EXIT

say()  { printf '%s\n' "$*"; }
step() { printf '\n%s==>%s %s%s%s\n' "$GRN" "$N" "$B" "$*" "$N"; }
info() { printf '    %s\n' "$*"; }
warn() { printf '%s warn:%s %s\n' "$YEL" "$N" "$*" >&2; }
die()  { printf '%serror:%s %s\n' "$RED" "$N" "$*" >&2; exit 1; }

# Prints what it would do under --dry-run, runs it otherwise. Every mutating
# command in this script goes through here, so --dry-run is trustworthy rather
# than mostly-trustworthy.
run() {
  if (( DRY_RUN )); then
    printf '    %s[dry-run]%s %s\n' "$DIM" "$N" "$*"
  else
    "$@"
  fi
}

confirm() {
  (( ASSUME_YES )) && return 0
  local reply
  read -r -p "    $1 [y/N] " reply || return 1
  [[ $reply == [yY] || $reply == [yY][eE][sS] ]]
}

# --- manifest --------------------------------------------------------------
#
# TSV, three columns: kind, path, detail. Append-only within a run, and a fresh
# run replaces the file -- a reinstall supersedes the previous one rather than
# accumulating stale entries. Kinds:
#
#   dir       a directory this script created (safe to rmdir if left empty)
#   file      a file it wrote; detail is the sha256 at write time, so removal
#             can tell "untouched since install" from "the user edited this"
#   backup    something that already existed; detail is where it was saved
#   packages  what was installed, recorded only -- nothing here removes them
#   themes    the Omarchy clone destination
#   masked    a systemd user unit this script masked
#   appended  a file it appended to rather than replaced (Alacritty's import)
#
record() {
  (( DRY_RUN )) && return 0
  printf '%s\t%s\t%s\n' "$1" "$2" "${3-}" >> "$MANIFEST"
}

# mkdir -p, but records only the directories that did not already exist, so a
# removal never proposes deleting ~/.config.
ensure_dir() {
  local d=$1
  [[ -d $d ]] && return 0
  run mkdir -p "$d"
  record dir "$d"
}

# Copy one file into place, backing up whatever was there. The backup keeps the
# path's shape under BACKUP_DIR ($HOME/.config/waybar/style.css ->
# $BACKUP_DIR/.config/waybar/style.css) so restoring is a plain cp -a back.
#
# A file that is already byte-identical to the source is not backed up: the
# documented update path is `git pull && ./install.sh`, and without this every
# re-run would snapshot thirty unchanged files. Only real divergence -- your
# edits, or an older version -- is worth keeping a copy of.
install_file() {
  local src=$1 dst=$2

  # dst exists here by definition, so the checksum is always safe to take --
  # unlike the one at the end, where under --dry-run nothing has been written.
  if [[ -e $dst && ! -L $dst ]] && cmp -s "$src" "$dst"; then
    record file "$dst" "sha256:$(sha256sum "$dst" | cut -d' ' -f1)"
    return 0
  fi

  if [[ -e $dst || -L $dst ]]; then
    local rel=${dst#"$HOME"/} bak
    bak="$BACKUP_DIR/$rel"
    run mkdir -p "$(dirname "$bak")"
    run cp -a "$dst" "$bak"
    record backup "$dst" "$bak"
    info "backed up $dst"
  fi

  run cp -f "$src" "$dst"
  if (( DRY_RUN )); then
    record file "$dst"
  else
    record file "$dst" "sha256:$(sha256sum "$dst" | cut -d' ' -f1)"
  fi
}

# --- arguments -------------------------------------------------------------

while (( $# )); do
  case $1 in
    --dry-run)     DRY_RUN=1 ;;
    --yes|-y)      ASSUME_YES=1 ;;
    --no-packages) DO_PACKAGES=0 ;;
    --no-aur)      DO_AUR=0 ;;
    --no-themes)   DO_THEMES=0 ;;
    -h|--help)     sed -n '3,34p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *)             die "unknown option: $1 (try --help)" ;;
  esac
  shift
done

# --- preflight -------------------------------------------------------------

(( EUID == 0 )) && die "run this as your normal user, not root -- it installs into \$HOME.
       The pacman steps call sudo themselves."

[[ -f $REPO/hypr/hyprland.lua ]] ||
  die "$REPO does not look like the omarchy-cherrypick checkout (no hypr/hyprland.lua)"

if (( DO_PACKAGES )) && ! command -v pacman >/dev/null; then
  warn "no pacman here -- skipping the package steps. Install the equivalents by hand;
       the lists are in README section 1."
  DO_PACKAGES=0
fi

# Overwriting the config of the compositor you are sitting in is survivable
# (nothing reloads until you tell it to) but it is not what the README asks
# for, and a bad edit then costs a logout instead of a window.
if [[ -n ${HYPRLAND_INSTANCE_SIGNATURE-} ]]; then
  warn "you are running inside Hyprland. The README suggests doing this from the
       Plasma session, so a broken config can't lock you out."
  confirm "carry on anyway?" || die "stopped."
fi

say "${B}omarchy-cherrypick${N}"
say "  source:    $REPO"
say "  manifest:  $MANIFEST"
say "  backups:   $BACKUP_DIR"
(( DRY_RUN )) && say "  ${DIM}dry run -- nothing will be changed${N}"
say ""
say "  This copies configs into ~/.config and scripts into ~/.local/bin,"
say "  backing up anything already there. Plasma is not touched."
(( DO_PACKAGES )) && say "  Packages will be installed with pacman$( ((DO_AUR)) && echo " and an AUR helper")."
(( DO_THEMES ))   && say "  Omarchy's themes ($OMARCHY_TAG, ~150 MB) will be cloned."

confirm "proceed?" || die "stopped."

if ! (( DRY_RUN )); then
  mkdir -p "$STATE_DIR" "$BACKUP_DIR"
  : > "$MANIFEST"
  printf '# omarchy-cherrypick install manifest -- %s\n' "$(date -Is)" >> "$MANIFEST"
  printf '# kind\tpath\tdetail\n' >> "$MANIFEST"
  record repo "$REPO"
fi

# --- 1. packages -----------------------------------------------------------

if (( DO_PACKAGES )); then
  step "Packages"
  run sudo pacman -S --needed "${PKGS_CORE[@]}"
  record packages "pacman" "${PKGS_CORE[*]}"

  if confirm "also install the optional set (${PKGS_OPTIONAL[*]})?"; then
    run sudo pacman -S --needed "${PKGS_OPTIONAL[@]}"
    record packages "pacman-optional" "${PKGS_OPTIONAL[*]}"
  else
    info "skipped -- each one backs a feature that hides itself when absent."
  fi

  if (( DO_AUR )); then
    AUR=""
    for helper in paru yay; do
      command -v "$helper" >/dev/null && { AUR=$helper; break; }
    done

    if [[ -n $AUR ]]; then
      run "$AUR" -S --needed "${PKGS_AUR[@]}"
      record packages "$AUR" "${PKGS_AUR[*]}"
    else
      warn "no paru or yay found -- the launcher is not installed. Install one, then:
       paru -S --needed ${PKGS_AUR[*]}"
    fi
  fi
else
  step "Packages (skipped)"
  info "README section 1 has the lists."
fi

# --- 2. Omarchy themes and templates ---------------------------------------

if (( DO_THEMES )); then
  step "Omarchy themes and templates ($OMARCHY_TAG)"

  if [[ -d $OMARCHY_SHARE/themes && -d $OMARCHY_SHARE/default/themed ]]; then
    info "already present at $OMARCHY_SHARE -- left alone."
  else
    tmp="$(mktemp -d)"
    # --branch is not decoration: the default branch is a development one, and
    # an untagged clone eventually gives you Omarchy 5 templates against these
    # 4.0 configs, with nothing to warn you.
    run git clone --depth 1 --branch "$OMARCHY_TAG" "$OMARCHY_REPO" "$tmp/omarchy"
    ensure_dir "$OMARCHY_SHARE/default"
    # Both destinations spelled out in full: `cp -r src dst/` renames src to dst
    # when dst does not exist, which would land the templates one level too high
    # and omarchy-theme would refuse to run.
    run cp -r "$tmp/omarchy/themes"         "$OMARCHY_SHARE/themes"
    run cp -r "$tmp/omarchy/default/themed" "$OMARCHY_SHARE/default/themed"
    run rm -rf "$tmp"
    record themes "$OMARCHY_SHARE"
    info "installed into $OMARCHY_SHARE"
  fi
else
  step "Omarchy themes (skipped)"
  info "omarchy-theme has nothing to render until you do README section 2."
fi

# --- 3. configs and scripts ------------------------------------------------

step "Configs"

ensure_dir "$HOME/.config/hypr"
ensure_dir "$HOME/.config/waybar"
ensure_dir "$HOME/.config/MangoHud"
ensure_dir "$HOME/.config/walker/themes/omarchy"
ensure_dir "$HOME/.config/swaync"
ensure_dir "$HOME/.config/mako"
ensure_dir "$HOME/.local/bin"

# theme.lua and hyprpaper.conf are gitignored -- they are omarchy-theme's
# output, not source -- so a checkout has nothing to copy for them and the
# first `omarchy-theme <name>` creates both.
for f in "$REPO"/hypr/*; do
  install_file "$f" "$HOME/.config/hypr/$(basename "$f")"
done

for f in "$REPO"/config/waybar/*; do
  install_file "$f" "$HOME/.config/waybar/$(basename "$f")"
done

install_file "$REPO/config/walker/style.css.tpl" "$HOME/.config/walker/themes/omarchy/style.css.tpl"

for f in "$REPO"/config/swaync/*; do
  install_file "$f" "$HOME/.config/swaync/$(basename "$f")"
done

install_file "$REPO/config/mako/config.tpl" "$HOME/.config/mako/config.tpl"
install_file "$REPO/config/MangoHud.conf"   "$HOME/.config/MangoHud/MangoHud.conf"

# gamemode expands neither ~ nor $HOME in a hook, so the llm-vram-release path
# has to be absolute; the shipped file carries a placeholder. The substitution
# is rendered into a temp file and *that* is installed, rather than copying the
# placeholder version and sed-ing it in place afterwards. It matters for
# re-runs: an in-place edit leaves the installed file permanently different
# from its source, so every later `git pull && ./install.sh` would read it as
# your divergence and snapshot it. Rendering first means the next run compares
# equal and leaves it alone.
GAMEMODE_TMP="$(mktemp)"
sed "s|/home/yourusername|$HOME|" "$REPO/config/gamemode.ini" > "$GAMEMODE_TMP"
install_file "$GAMEMODE_TMP" "$HOME/.config/gamemode.ini"

step "Scripts"
for f in "$REPO"/bin/*; do
  dst="$HOME/.local/bin/$(basename "$f")"
  install_file "$f" "$dst"
  run chmod +x "$dst"
done

# --- 4. Alacritty import ---------------------------------------------------
#
# omarchy-theme writes ~/.config/alacritty/omarchy-theme.toml but will not
# touch alacritty.toml: that file is the user's. Nothing imports the generated
# colours until the import line exists.

step "Alacritty theme import"
ALACRITTY_CONF="$HOME/.config/alacritty/alacritty.toml"

if ! command -v alacritty >/dev/null; then
  info "alacritty not installed -- skipped."
elif [[ -f $ALACRITTY_CONF ]] && grep -q 'omarchy-theme.toml' "$ALACRITTY_CONF"; then
  info "import already present -- left alone."
elif [[ -f $ALACRITTY_CONF ]] && grep -q '^\[general\]' "$ALACRITTY_CONF"; then
  # TOML rejects a duplicate table, so appending a second [general] would break
  # the config outright. This is the one case the script refuses to guess at.
  warn "$ALACRITTY_CONF already has a [general] table. Add these two keys to it
       yourself -- a second [general] is a TOML error:

           import = [\"~/.config/alacritty/omarchy-theme.toml\"]
           live_config_reload = true"
else
  ensure_dir "$HOME/.config/alacritty"
  if (( DRY_RUN )); then
    info "[dry-run] append [general] import block to $ALACRITTY_CONF"
  else
    cat >> "$ALACRITTY_CONF" <<'EOF'

[general]
import = ["~/.config/alacritty/omarchy-theme.toml"]
live_config_reload = true
EOF
    record appended "$ALACRITTY_CONF" "[general] import block"
    info "added the import block"
  fi
fi

# --- 5. mako, if it is installed alongside swaync --------------------------
#
# Both daemons ship a D-Bus activation file claiming
# org.freedesktop.Notifications, so with both installed the first notification
# after login makes systemd try to activate mako while swaync already owns the
# name. Harmless, but it fills the journal. Masking silences it and keeps mako
# on disk as the fallback -- at the cost of an unmask when swapping back.

if command -v mako >/dev/null && command -v swaync >/dev/null; then
  step "mako / swaync bus name"
  if [[ "$(systemctl --user is-enabled mako.service 2>/dev/null)" == masked ]]; then
    info "mako.service already masked."
  elif confirm "mask mako.service so it stops racing swaync for the bus name?"; then
    run systemctl --user mask mako.service
    record masked "mako.service"
  else
    info "left alone -- expect 'Two services allocated for the same bus name' in the journal."
  fi
fi

# --- done ------------------------------------------------------------------

step "Installed"

if (( DRY_RUN )); then
  say ""
  say "  Dry run -- nothing was changed."
  exit 0
fi

say ""
say "  Manifest: $MANIFEST"
say "  Backups:  $BACKUP_DIR"
say ""
say "${B}  Three things the script will not do for you:${N}"
say ""
say "  1. ${B}Keyboard layout.${N} hypr/hyprland.lua sets input.kb_layout = \"fi\"."
say "     This is the one edit you cannot skip:"
say "         \$EDITOR ~/.config/hypr/hyprland.lua"
say ""
say "  2. ${B}Monitor.${N} The block hardcodes 3440x1440@164.90 on DP-3. Safe to"
say "     leave -- a catch-all hl.monitor above it brings an unknown display up"
say "     at its preferred mode -- but yours is worth filling in."
say ""
say "  3. ${B}Three binds name Finnish keysyms${N} and are dead on other layouts."
say "     A keysym your layout cannot produce registers fine and never fires."
say "     On a US layout:"
say "         sed -i 's/\\.\\. \"plus\"/.. \"minus\"/g; s/\\.\\. \"dead_acute\"/.. \"equal\"/g; s/SUPER + section/SUPER + grave/' \\"
say "           ~/.config/hypr/omarchy-bindings.lua"
say ""
say "${B}  Then log out and pick Hyprland at the login screen.${N}"
say ""
say "  ${B}Apply a theme from inside that session${N}, not from here:"
say ""
say "         omarchy-theme          # list what is installed"
say "         omarchy-theme nord     # apply one"
say ""
say "  Two reasons this is not done for you. It reloads Hyprland, waybar,"
say "  hyprpaper and swaync in place -- which only works in the session they"
say "  belong to, so run from here it would write files and change nothing you"
say "  can see. And it also colours alacritty, kitty, foot and btop, which you"
say "  may well be using in Plasma; an installer should not repaint those"
say "  behind your back."
say ""
say "  Until you do, Hyprland comes up with no wallpaper and default borders."
say "  That is cosmetic -- theme.lua is loaded through a guarded dofile and the"
say "  bar ships a fallback colors.css, so nothing is broken."
say ""
say "  If it drops you straight back to the login screen, pick Plasma and read"
say "  the log in the same boot -- it names the file and line that broke:"
say ""
say "         cat \"\$XDG_RUNTIME_DIR\"/hypr/*/hyprland.log"
say ""
