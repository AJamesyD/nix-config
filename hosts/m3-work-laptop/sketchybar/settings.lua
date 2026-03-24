local label_family = "SF Pro"
local icon_family = "BlexMono Nerd Font"

local icon_size = 23.0
local label_size = 17.0

return {
  paddings = 6,
  icon_size = icon_size,
  label_size = label_size,
  item_height = 36,
  popup_item_height = 28,
  item_radius = 10,
  group_paddings = 8,
  animation_duration = 15,

  -- Consistent internal padding for items with a background pill.
  -- icon_only: symmetric padding for icon-only items (apple, spaces, separator).
  -- icon_label: left padding for icon in icon+label pills; label gets label_right on the other end.
  icon_padding = 8,
  label_right_padding = 10,

  -- Reusable font specs: items reference these instead of building inline tables.
  -- Each is a complete { family, style, size } table ready for sketchybar's font property.
  font = {
    -- Labels (SF Pro)
    label = { family = label_family, style = "Regular", size = label_size },
    label_light = { family = label_family, style = "Light", size = label_size },
    label_medium = { family = label_family, style = "Medium", size = label_size },
    label_bold = { family = label_family, style = "Bold", size = 14.0 },
    label_small = { family = label_family, style = "Light", size = 12.0 },

    -- Icons (Nerd Font glyphs)
    icon = { family = icon_family, style = "Regular", size = icon_size },
    icon_bold = { family = icon_family, style = "Bold", size = icon_size },
    icon_small = { family = icon_family, style = "Bold", size = icon_size - 2 },
    icon_large = { family = icon_family, style = "Bold", size = 28.0 },
  },
}
