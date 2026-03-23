local colors = require("colors")
local sbar = require("sbar")

sbar.bar({
  topmost = "window",
  height = 48,
  color = colors.bar.bg,
  border_color = colors.bar.border,
  border_width = 0,
  shadow = true,
  position = "top",
  sticky = true,
  padding_right = 14,
  padding_left = 14,
  corner_radius = 0,
  y_offset = 0,
  margin = 0,
  blur_radius = 20,
  notch_width = 220,
  notch_offset = 0,
  display = "main",
  font_smoothing = true,
})
