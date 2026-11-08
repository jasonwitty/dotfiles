-- Catppuccin Frappé — window look carried over from the old ML4W setup
-- (decorations/default.conf "Rounding All Blur No Shadows" + windows/border-2.conf)
local active_border_color = "rgba(c6d0f5ff)"
local inactive_border_color = "rgba(8caaeeff)"

hl.config({
  general = {
    gaps_in = 10,
    gaps_out = 20,
    border_size = 2,
    col = {
      active_border = active_border_color,
      inactive_border = inactive_border_color,
    },
  },

  group = {
    col = {
      border_active = active_border_color,
      border_inactive = inactive_border_color,
    },
  },

  decoration = {
    rounding = 10,
    active_opacity = 1.0,
    inactive_opacity = 0.9,
    fullscreen_opacity = 1.0,

    blur = {
      enabled = true,
      size = 4,
      passes = 4,
      new_optimizations = true,
      ignore_opacity = true,
      xray = true,
    },

    shadow = {
      enabled = true,
      range = 32,
      render_power = 2,
      color = "rgba(00000050)",
    },
  },
})
