local colors = require("colors")
local icons = require("icons")
local settings = require("settings")
local sbar = require("sbar")
-- Loaded for future sleep-guard use once media polling is added
local _utils = require("utils")

local MAX_TITLE_LEN = 30

local media_token = 0

local media = sbar.add("item", "media", {
  position = "right",
  icon = {
    string = icons.media.not_playing,
    color = colors.green,
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
    string = "",
    color = colors.fg_dim,
    font = {
      family = settings.font.nerd,
      style = settings.font.style.medium,
      size = settings.label_size,
    },
    max_chars = MAX_TITLE_LEN,
    padding_right = 8,
  },
  background = {
    color = colors.transparent,
    corner_radius = settings.item_radius,
    height = settings.item_height,
  },
  padding_left = 2,
  padding_right = 2,
  drawing = false,
})

media:subscribe("media_change", function(env)
  media_token = media_token + 1
  local _current = media_token

  if not env.INFO then
    media:set({ drawing = false })
    return
  end

  local state = env.INFO.state
  local artist = env.INFO.artist or ""
  local title = env.INFO.title or ""

  if state == "playing" then
    local label = artist ~= "" and (artist .. " - " .. title) or title
    sbar.animate("tanh", settings.animation_duration, function()
      media:set({
        drawing = true,
        icon = { string = icons.media.play, color = colors.green },
        label = { string = label },
        background = { color = colors.item_bg },
      })
    end)
  elseif state == "paused" then
    local label = artist ~= "" and (artist .. " - " .. title) or title
    sbar.animate("tanh", settings.animation_duration, function()
      media:set({
        drawing = true,
        icon = { string = icons.media.pause, color = colors.yellow },
        label = { string = label },
        background = { color = colors.with_alpha(colors.item_bg, 0x66) },
      })
    end)
  else
    sbar.animate("tanh", settings.animation_duration, function()
      media:set({ drawing = false })
    end)
  end
end)

media:subscribe("mouse.clicked", function(env)
  if env.BUTTON == "right" then
    sbar.exec("nowplaying-cli next 2>/dev/null" .. " || osascript -e 'tell application \"Spotify\" to next track'")
  else
    sbar.exec(
      "nowplaying-cli togglePlayPause 2>/dev/null" .. " || osascript -e 'tell application \"Spotify\" to playpause'"
    )
  end
end)

media:subscribe("mouse.scrolled", function(env)
  if tonumber(env.SCROLL_DELTA) > 0 then
    sbar.exec("nowplaying-cli next 2>/dev/null" .. " || osascript -e 'tell application \"Spotify\" to next track'")
  else
    sbar.exec(
      "nowplaying-cli previous 2>/dev/null" .. " || osascript -e 'tell application \"Spotify\" to previous track'"
    )
  end
end)
