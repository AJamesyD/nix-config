local colors = require("colors")
local settings = require("settings")
local sbar = require("sbar")

-- Mode indicator: shows in the bar when a non-main mode is active
local mode_item = sbar.add("item", "aerospace_mode", {
  position = "left",
  drawing = false,
  updates = "on",
  icon = {
    font = {
      family = settings.font.text,
      style = settings.font.style.bold,
      size = 12.0,
    },
    color = colors.bg1,
  },
  label = { drawing = false },
  background = {
    color = colors.yellow,
    corner_radius = settings.item_radius,
    height = settings.item_height,
  },
  padding_left = 4,
  padding_right = 4,
  popup = {
    align = "left",
    height = 28,
  },
})

-- Key descriptions for each mode (the "which-key" data)
local mode_keys = {
  service = {
    { key = "r", desc = "flatten (reset layout)" },
    { key = "b", desc = "balance sizes" },
    { key = "f", desc = "toggle float/tile" },
    { key = "x", desc = "close other windows" },
    { key = "n", desc = "native fullscreen" },
    { key = "h/j/k/l", desc = "join with direction" },
    { key = "H/J/K/L", desc = "swap direction" },
    { key = "esc", desc = "back to main" },
  },
}

-- Create popup items for each mode
local popup_items = {}
for mode_name, keys in pairs(mode_keys) do
  popup_items[mode_name] = {}
  for i, entry in ipairs(keys) do
    local item = sbar.add("item", "mode_key_" .. mode_name .. "_" .. i, {
      position = "popup.aerospace_mode",
      drawing = false,
      icon = {
        string = entry.key,
        font = {
          family = settings.font.numbers,
          style = settings.font.style.bold,
          size = 13.0,
        },
        color = colors.yellow,
        width = 80,
        align = "right",
      },
      label = {
        string = entry.desc,
        font = {
          family = settings.font.text,
          style = settings.font.style.regular,
          size = 13.0,
        },
        color = colors.fg,
      },
      background = { color = colors.transparent },
    })
    table.insert(popup_items[mode_name], item)
  end
end

-- Listen for mode change events
sbar.add("event", "aerospace_mode_change")

mode_item:subscribe("aerospace_mode_change", function(env)
  local mode = env.AEROSPACE_MODE or "main"

  if mode == "main" then
    mode_item:set({
      drawing = false,
      popup = { drawing = false },
    })
    for _, items in pairs(popup_items) do
      for _, item in ipairs(items) do
        item:set({ drawing = false })
      end
    end
  else
    local label = mode:upper():sub(1, 3)
    mode_item:set({
      drawing = true,
      icon = { string = label },
      popup = { drawing = true },
    })
    for mode_name, items in pairs(popup_items) do
      local show = (mode_name == mode)
      for _, item in ipairs(items) do
        item:set({ drawing = show })
      end
    end
  end
end)
