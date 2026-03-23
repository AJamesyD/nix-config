local colors = require("colors")
local icons = require("icons")
local settings = require("settings")
local sbar = require("sbar")

local cal = sbar.add("item", "calendar", {
  position = "right",
  update_freq = 30,
  icon = {
    string = icons.calendar,
    color = colors.orange,
    font = {
      family = settings.font.nerd,
      style = settings.font.style.medium,
      size = settings.icon_size,
    },
    y_offset = 1,
    padding_left = 8,
    padding_right = 4,
  },
  label = {
    color = colors.fg,
    font = {
      family = settings.font.label,
      style = settings.font.style.medium,
      size = settings.label_size,
    },
    padding_right = 10,
  },
  background = {
    color = colors.item_bg,
    corner_radius = settings.item_radius,
    height = settings.item_height,
  },
  padding_left = 4,
  padding_right = 4,
})

local function update()
  cal:set({ label = { string = os.date("%a %d %b  %H:%M") } })
end

cal:subscribe({ "routine", "forced", "system_woke" }, function(_)
  update()
end)

cal:subscribe("mouse.clicked", function(_)
  sbar.exec("open -a 'Microsoft Outlook'")
end)

update()
