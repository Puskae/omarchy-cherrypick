/* ------------------------------------------------------------------ */
/* Omarchy palette, layered over swaync's own stylesheet.              */
/*                                                                     */
/* swaync loads /etc/xdg/swaync/style.css first and this file on top,  */
/* so only the colour variables are redefined here -- the 500+ layout  */
/* rules stay upstream's and track the installed version instead of a  */
/* fork. `omarchy-theme <name>` renders this to style.css beside it.   */
/*                                                                     */
/* Not an upstream Omarchy file -- Omarchy's notifications are a       */
/* Quickshell component. The double-brace slots are the six palette    */
/* keys every Omarchy theme defines, plus the "_rgb" triplets swaync   */
/* needs for its alpha-composited backgrounds.                         */
/* ------------------------------------------------------------------ */

:root {
  --cc-bg: rgba({{ background_rgb }}, 0.94);
  --noti-bg: {{ background_rgb }};
  --noti-bg-alpha: 0.96;
  --noti-bg-darker: {{ background }};
  --noti-bg-hover: {{ selection }};
  --noti-bg-focus: rgba({{ accent_rgb }}, 0.25);
  --noti-border-color: {{ selection }};
  --noti-close-bg: {{ selection }};
  --noti-close-bg-hover: {{ muted }};

  --text-color: {{ foreground }};
  --text-color-disabled: {{ muted }};
  --bg-selected: {{ accent }};

  /* Flat and square, like the bar and the launcher. */
  --border-radius: 0px;
  --border: 1px solid {{ selection }};
  --notification-shadow: none;

  --font-size-summary: 14px;
  --font-size-body: 13px;
}

/* The pre-:root fallback colours further up the stock sheet are still read by
   some widgets, so redefine those too rather than leaving grey behind. */
@define-color cc-bg {{ background }};
@define-color noti-border-color {{ selection }};
@define-color noti-bg {{ background }};
@define-color noti-bg-opaque {{ background }};
@define-color noti-bg-darker {{ background }};
@define-color noti-bg-hover {{ selection }};
@define-color noti-bg-hover-opaque {{ selection }};
@define-color noti-bg-focus {{ selection }};
@define-color noti-close-bg {{ selection }};
@define-color noti-close-bg-hover {{ muted }};
@define-color text-color {{ foreground }};
@define-color text-color-disabled {{ muted }};
@define-color bg-selected {{ accent }};

.control-center,
.floating-notifications {
  font-family: "MesloLGM Nerd Font", "Noto Sans", sans-serif;
}

/* The panel itself: one accent edge, no rounding. */
.control-center {
  border: 1px solid {{ accent }};
  background: rgba({{ background_rgb }}, 0.94);
}

/* Widget headers -- "Notifications", "Do not disturb". */
.widget-title,
.widget-dnd {
  color: {{ foreground }};
  font-weight: bold;
  padding: 6px 4px;
}

.widget-title > button,
.widget-dnd > switch {
  border: 1px solid {{ selection }};
  border-radius: 0px;
  background: transparent;
  color: {{ foreground }};
}

.widget-title > button:hover {
  background: {{ selection }};
}

.widget-dnd > switch:checked {
  background: {{ accent }};
}

/* Critical notifications keep the red edge they had under mako. */
.notification.critical,
.critical .notification-background .notification {
  border: 1px solid {{ red }};
}

.notification-action,
.notification-default-action {
  border-radius: 0px;
}

.notification-action:hover,
.notification-default-action:hover {
  background: {{ selection }};
}

/* Empty-state text ("Nothing to see"). */
.control-center .notification-row .notification-background .notification .notification-content .body,
.blank-window label {
  color: {{ muted }};
}

.widget-mpris .widget-mpris-player {
  background: rgba({{ selection_rgb }}, 0.5);
  border-radius: 0px;
}

.widget-mpris .widget-mpris-title {
  color: {{ foreground }};
  font-weight: bold;
}

.widget-mpris .widget-mpris-subtitle {
  color: {{ muted }};
}

/* Per-app volume rows. Upstream's sheet styles .per-app-volume with
   var(--noti-bg-alt) and then never defines it -- the rows come out with no
   background at all -- so it is defined here. */
:root {
  --noti-bg-alt: {{ selection }};
}

.widget-volume,
.widget-buttons-grid {
  background: transparent;
  padding: 4px 2px;
}

.widget-volume > box > label {
  color: {{ foreground }};
}

.per-app-volume {
  background-color: rgba({{ selection_rgb }}, 0.5);
  border-radius: 0px;
}

/* Sliders: accent up to the handle, selection for the rest of the track. */
.widget-volume scale trough {
  background: {{ selection }};
  border-radius: 0px;
  min-height: 6px;
}

.widget-volume scale trough highlight {
  background: {{ accent }};
  border-radius: 0px;
}

/* Only colour the handle -- do NOT set min-width/min-height on it. Adwaita
   gives the handle a negative margin, so a small min size computes to a
   negative one, GTK warns "sizes must be >= 0", and the handle ends up with no
   hit area. Sizing belongs on the scale itself. */
.widget-volume scale {
  min-height: 22px;
}

.widget-volume scale slider {
  background: {{ foreground }};
  border: none;
  border-radius: 0px;
}

/* Brightness buttons. Square, quiet until hovered -- the same treatment the
   bar's modules get. (This is a buttons-grid rather than a slider on purpose:
   see the note in the README about swaync's slider widget cancelling its own
   drag gesture.) */
.widget-buttons-grid > flowbox > flowboxchild > button {
  background: transparent;
  border: 1px solid {{ selection }};
  border-radius: 0px;
  color: {{ foreground }};
  padding: 6px 4px;
  margin: 2px;
}

.widget-buttons-grid > flowbox > flowboxchild > button:hover {
  background: {{ selection }};
}

.widget-buttons-grid > flowbox > flowboxchild > button.toggle:checked {
  background: {{ accent }};
  color: {{ background }};
}

/* Inhibitors -- who is suppressing notifications right now (gamemode, mostly). */
.widget-inhibitors > label {
  color: {{ foreground }};
  font-size: 1rem;
  font-weight: bold;
}

.widget-inhibitors > button {
  border: 1px solid {{ selection }};
  border-radius: 0px;
  background: transparent;
  color: {{ foreground }};
}

.widget-inhibitors > button:hover {
  background: {{ selection }};
}
