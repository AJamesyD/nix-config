local colors = require("colors")
local settings = require("settings")
local sbar = require("sbar")

-- Cache app name -> bundle ID to avoid repeated osascript calls (~90ms each)
local bundle_cache = {}

local front_app_icon = sbar.add("item", "front_app.icon", {
  position = "left",
  icon = {
    drawing = false,
  },
  label = {
    drawing = false,
  },
  background = {
    color = colors.transparent,
    image = { scale = 0.9 },
    padding_left = 4,
    padding_right = 0,
  },
  padding_left = 4,
  padding_right = 0,
})

local front_app_name = sbar.add("item", "front_app.name", {
  position = "left",
  icon = { drawing = false },
  label = {
    string = "…",
    font = {
      family = settings.font.label,
      style = settings.font.style.semibold,
      size = settings.label_size,
    },
    color = colors.fg_dim,
    padding_left = 0,
    padding_right = 10,
  },
  background = { color = colors.transparent },
  padding_left = 0,
  padding_right = 0,
})

sbar.add("bracket", "front_app.bracket", {
  front_app_icon.name,
  front_app_name.name,
}, {
  background = {
    color = colors.item_bg,
    corner_radius = settings.item_radius,
    height = settings.item_height,
  },
})

local function set_app_icon(bundle_id)
  front_app_icon:set({
    background = {
      image = "app." .. bundle_id,
      drawing = true,
    },
  })
end

front_app_icon:subscribe("front_app_switched", function(env)
  local app_name = env.INFO or ""
  front_app_name:set({
    label = { string = app_name },
  })

  local cached = bundle_cache[app_name]
  if cached then
    set_app_icon(cached)
    return
  end

  sbar.exec("osascript -e 'id of app \"" .. app_name .. "\"' 2>/dev/null", function(result)
    local bundle_id = result and result:match("^%s*(.-)%s*$") or ""
    if bundle_id ~= "" then
      bundle_cache[app_name] = bundle_id
      set_app_icon(bundle_id)
    end
  end)
end)
