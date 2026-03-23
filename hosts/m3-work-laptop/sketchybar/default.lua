local colors = require("colors")
local settings = require("settings")
local sbar = require("sbar")

sbar.default({
  updates = "when_shown",
  icon = {
    font = settings.font.icon,
    color = colors.fg,
    padding_left = settings.paddings,
    padding_right = settings.paddings,
  },
  label = {
    font = settings.font.label,
    color = colors.fg,
    padding_left = settings.paddings,
    padding_right = settings.paddings,
  },
  background = {
    height = settings.item_height,
    corner_radius = settings.item_radius,
    color = colors.transparent,
    border_color = colors.transparent,
    border_width = 0,
  },
  popup = {
    background = {
      color = colors.popup.bg,
      border_color = colors.popup.border,
      border_width = 1,
      corner_radius = settings.item_radius,
    },
    blur_radius = 20,
  },
})
