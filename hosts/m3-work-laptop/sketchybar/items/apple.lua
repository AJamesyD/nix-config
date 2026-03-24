local colors = require("colors")
local icons = require("icons")
local settings = require("settings")
local sbar = require("sbar")

local apple = sbar.add("item", "apple.logo", {
  position = "left",
  icon = {
    string = icons.apple,
    font = settings.font.icon_large,
    color = colors.fg,
    y_offset = 1,
    padding_left = 10,
    padding_right = 10,
  },
  label = { drawing = false },
  background = {
    color = colors.item_bg,
    corner_radius = settings.item_radius,
    height = settings.item_height,
  },
  padding_left = 5,
  padding_right = 2,
})

local popup_items = {
  { name = "preferences", label = "Preferences", icon = icons.preferences, cmd = "open -a 'System Preferences'" },
  { name = "activity", label = "Activity", icon = icons.activity, cmd = "open -a 'Activity Monitor'" },
  { name = "lock", label = "Lock Screen", icon = icons.lock, cmd = "pmset displaysleepnow" },
  {
    name = "restart",
    label = "Restart",
    icon = icons.power.restart,
    cmd = "osascript -e 'tell app \"System Events\" to restart'",
  },
  {
    name = "shutdown",
    label = "Shut Down",
    icon = icons.power.shutdown,
    cmd = "osascript -e 'tell app \"System Events\" to shut down'",
  },
}

for _, def in ipairs(popup_items) do
  local popup_item = sbar.add("item", "apple.popup." .. def.name, {
    position = "popup.apple.logo",
    icon = {
      string = def.icon,
      color = colors.fg,
      font = settings.font.icon,
      padding_left = settings.icon_padding,
      padding_right = 4,
    },
    label = {
      string = def.label,
      color = colors.fg,
      font = settings.font.label_medium,
      padding_right = settings.icon_padding,
    },
    background = {
      color = colors.transparent,
      height = settings.popup_item_height,
      corner_radius = settings.item_radius - 3,
    },
  })

  popup_item:subscribe("mouse.clicked", function(_)
    sbar.exec(def.cmd)
    apple:set({ popup = { drawing = false } })
  end)

  popup_item:subscribe("mouse.entered", function(_)
    popup_item:set({ background = { color = colors.with_alpha(colors.grey, 0x66) } })
  end)

  popup_item:subscribe("mouse.exited", function(_)
    popup_item:set({ background = { color = colors.transparent } })
  end)
end

apple:subscribe("mouse.clicked", function(_)
  apple:set({ popup = { drawing = "toggle" } })
end)

apple:subscribe("mouse.entered.global", function(_)
  apple:set({ popup = { drawing = false } })
end)
