/* walker, in the Omarchy spirit: flat, square, low-contrast until something is
   selected. Rendered by `omarchy-theme <name>` into style.css beside this file.
 *
 * This is not an upstream Omarchy file. Omarchy 4.0 has no walker template --
 * its launcher is a Quickshell component, not walker -- so the look here is an
 * interpretation of its bar and window styling, matched to the same palette.
 *
 * The double-brace slots below are keys from the theme's colors.toml. Only the
 * six that every Omarchy theme defines are used: background, foreground,
 * accent, muted, selection, red.
 * Everything else is derived with GTK's own lighter()/darker()/alpha().
 *
 * GTK4 CSS: no custom properties, no calc() on colors -- hence the functions. */

@define-color window_bg_color {{ background }};
@define-color accent_bg_color {{ accent }};
@define-color theme_fg_color {{ foreground }};
@define-color theme_muted_color {{ muted }};
@define-color theme_selection_color {{ selection }};
@define-color error_bg_color {{ red }};
@define-color error_fg_color {{ background }};

* {
  all: unset;
  font-family: "MesloLGM Nerd Font", "Noto Sans Mono", monospace;
}

popover {
  background: @window_bg_color;
  border: 1px solid @accent_bg_color;
  border-radius: 0;
  padding: 10px;
}

.normal-icons {
  -gtk-icon-size: 16px;
}

.large-icons {
  -gtk-icon-size: 32px;
}

scrollbar {
  opacity: 0;
}

/* The launcher box. Square and bordered rather than rounded and shadowed,
   matching border_size = 2 / rounding = 0 in omarchy-looknfeel.lua. */
.box-wrapper {
  background: @window_bg_color;
  padding: 16px;
  border-radius: 0;
  border: 2px solid @accent_bg_color;
  box-shadow: none;
}

.preview-box,
.elephant-hint,
.placeholder {
  color: @theme_muted_color;
}

.search-container {
  border-radius: 0;
}

.input {
  caret-color: @accent_bg_color;
  background: @theme_selection_color;
  padding: 10px;
  color: @theme_fg_color;
  border-radius: 0;
  border-bottom: 2px solid transparent;
}

.input:focus,
.input:active {
  border-bottom: 2px solid @accent_bg_color;
}

.input placeholder {
  color: @theme_muted_color;
}

.input selection {
  background: alpha(@accent_bg_color, 0.35);
  color: @theme_fg_color;
}

.list {
  color: @theme_fg_color;
}

.item-box {
  border-radius: 0;
  padding: 8px 10px;
  border-left: 2px solid transparent;
}

/* Selection reads as an accent bar on the left plus a tint, the same shape the
   active workspace takes in the bar. */
child:selected .item-box,
row:selected .item-box {
  background: alpha(@accent_bg_color, 0.18);
  border-left: 2px solid @accent_bg_color;
}

.item-quick-activation {
  background: alpha(@accent_bg_color, 0.25);
  border-radius: 0;
  padding: 10px;
  color: @theme_fg_color;
}

.item-subtext {
  font-size: 12px;
  color: @theme_muted_color;
}

.providerlist .item-subtext {
  font-size: unset;
  color: @theme_muted_color;
}

.item-image-text {
  font-size: 28px;
}

.preview {
  border: 1px solid alpha(@accent_bg_color, 0.35);
  border-radius: 0;
  color: @theme_fg_color;
}

.calc .item-text {
  font-size: 24px;
  color: @accent_bg_color;
}

.symbols .item-image {
  font-size: 24px;
}

.todo.done .item-text-box {
  opacity: 0.25;
}

.todo.urgent {
  font-size: 24px;
  color: @error_bg_color;
}

.todo.active {
  font-weight: bold;
}

.bluetooth.disconnected {
  color: @theme_muted_color;
}

.preview .large-icons {
  -gtk-icon-size: 64px;
}

.keybinds {
  padding-top: 10px;
  border-top: 1px solid @theme_selection_color;
  font-size: 12px;
  color: @theme_muted_color;
}

.keybind-button {
  color: @theme_muted_color;
}

.keybind-button:hover {
  color: @theme_fg_color;
}

.keybind-bind {
  text-transform: lowercase;
  color: @theme_muted_color;
}

.keybind-label {
  padding: 2px 4px;
  border-radius: 0;
  border: 1px solid @theme_muted_color;
}

.error {
  padding: 10px;
  background: @error_bg_color;
  color: @error_fg_color;
}

:not(.calc).current {
  font-style: italic;
}

.preview-content.archlinuxpkgs,
.preview-content.dnfpackages,
.preview-content.aptpackages {
  font-family: monospace;
}
