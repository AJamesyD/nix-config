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

-- Mode colors for visual feedback (analogous to tmux prefix/copy mode colors)
local mode_colors = {
  service = colors.yellow,
}

-- Default border color (must match bordersrc active_color)
local default_border_color = "0xffe1e3e4"

-- Listen for mode change events
sbar.add("event", "aerospace_mode_change")

mode_item:subscribe("aerospace_mode_change", function(env)
  local mode = env.AEROSPACE_MODE or "main"

  if mode == "main" then
    -- Restore defaults: hide indicator, dismiss popup, restore colors
    mode_item:set({
      drawing = false,
      popup = { drawing = false },
    })
    for _, items in pairs(popup_items) do
      for _, item in ipairs(items) do
        item:set({ drawing = false })
      end
    end
    -- Restore bar and border colors
    sbar.bar({ color = colors.bar.bg })
    sbar.exec("borders active_color=" .. default_border_color)
  else
    local label = mode:upper():sub(1, 3)
    local mode_color = mode_colors[mode] or colors.yellow
    local mode_color_hex = string.format("0xff%06x", mode_color % 0x01000000)

    mode_item:set({
      drawing = true,
      icon = { string = label },
      background = { color = mode_color },
      popup = { drawing = true },
    })
    for mode_name, items in pairs(popup_items) do
      local show = (mode_name == mode)
      for _, item in ipairs(items) do
        item:set({ drawing = show })
      end
    end
    -- Tint bar and borders to match mode color
    sbar.bar({ color = colors.with_alpha(mode_color, 0x44) })
    sbar.exec("borders active_color=" .. mode_color_hex)
  end
end)
