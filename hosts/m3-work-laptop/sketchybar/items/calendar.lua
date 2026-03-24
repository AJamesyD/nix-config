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
    font = settings.font.icon,
    y_offset = 1,
    padding_left = settings.icon_padding,
    padding_right = 4,
  },
  label = {
    color = colors.fg_dim,
    font = settings.font.label,
    padding_right = settings.label_right_padding,
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
