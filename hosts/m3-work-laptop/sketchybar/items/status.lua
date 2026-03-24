local colors = require("colors")
local icons = require("icons")
local settings = require("settings")
local sbar = require("sbar")
local utils = require("utils")

-- Collapsible system stats: CPU, memory, disk, network throughput.
-- The separator toggles visibility of the stat items.

local function merge(base, overrides)
  local result = {}
  for k, v in pairs(base) do
    result[k] = v
  end
  for k, v in pairs(overrides) do
    if type(v) == "table" and type(result[k]) == "table" then
      result[k] = merge(result[k], v)
    else
      result[k] = v
    end
  end
  return result
end

local stats_visible = false

local separator = sbar.add("item", "status.separator", {
  position = "right",
  icon = {
    string = icons.status.separator,
    color = colors.fg,
    font = settings.font.icon_bold,
    y_offset = 1,
    padding_left = settings.icon_padding,
    padding_right = settings.icon_padding,
  },
  label = { drawing = false },
  background = {
    color = colors.transparent,
    corner_radius = settings.item_radius,
    height = settings.item_height,
  },
  padding_left = 4,
  padding_right = 4,
})

local stat_defaults = {
  position = "right",
  icon = {
    font = settings.font.icon_small,
    y_offset = 1,
    padding_left = 4,
    padding_right = 2,
  },
  label = {
    font = settings.font.label_bold,
    color = colors.fg_dim,
    padding_right = 4,
  },
  background = {
    color = colors.transparent,
    corner_radius = settings.item_radius,
    height = settings.item_height,
  },
  drawing = false,
  padding_left = 0,
  padding_right = 0,
}

local cpu = sbar.add(
  "item",
  "status.cpu",
  merge(stat_defaults, {
    updates = "on",
    icon = { string = icons.status.cpu, color = colors.blue },
  })
)

local memory = sbar.add(
  "item",
  "status.memory",
  merge(stat_defaults, {
    update_freq = 10,
    icon = { string = icons.status.memory, color = colors.magenta },
  })
)

local disk = sbar.add(
  "item",
  "status.disk",
  merge(stat_defaults, {
    update_freq = 60,
    icon = { string = icons.status.disk, color = colors.yellow },
  })
)

-- Network items: item-level y_offset stacks them vertically,
-- background.padding_right on net_up creates the horizontal overlap.
-- Created without stat_defaults merge to match khanelinix exactly.
local net_down = sbar.add("item", "status.net_down", {
  position = "right",
  drawing = false,
  y_offset = -9,
  background = { padding_left = 0 },
  icon = {
    string = icons.status.network_down,
    color = colors.green,
    width = 22,
    font = settings.font.icon_small,
  },
  label = {
    width = 65,
    align = "right",
    font = settings.font.label_small,
    color = colors.fg_dim,
  },
})

local net_up = sbar.add("item", "status.net_up", {
  position = "right",
  drawing = false,
  y_offset = 9,
  background = { padding_right = -87 },
  icon = {
    string = icons.status.network_up,
    color = colors.green,
    width = 22,
    font = settings.font.icon_small,
  },
  label = {
    width = 65,
    align = "right",
    font = settings.font.label_small,
    color = colors.fg_dim,
  },
})

local stat_items = { cpu, memory, disk, net_down, net_up }

local function close_stats()
  sbar.animate("tanh", settings.animation_duration, function()
    cpu:set({ background = { padding_right = -10 } })
    memory:set({ background = { padding_right = -50 } })
    disk:set({ background = { padding_right = -40 } })
    net_up:set({ background = { padding_right = -87 } })
    net_down:set({ background = { padding_right = -50 } })
  end)
  separator:set({ icon = { string = icons.status.separator } })
  sbar.exec("sleep 0.1", function()
    for _, item in ipairs(stat_items) do
      item:set({ drawing = false })
    end
  end)
end

local function open_stats()
  separator:set({ icon = { string = icons.status.separator_open } })
  for _, item in ipairs(stat_items) do
    item:set({ drawing = true })
  end
  sbar.animate("tanh", settings.animation_duration, function()
    cpu:set({ background = { padding_right = 0 } })
    memory:set({ background = { padding_right = 0 } })
    disk:set({ background = { padding_right = 0 } })
    net_up:set({ background = { padding_right = -87 } })
    net_down:set({ background = { padding_right = 0 } })
  end)
end

local function set_stats_visible(visible)
  if visible then
    open_stats()
  else
    close_stats()
  end
end

separator:subscribe("mouse.clicked", function(_)
  stats_visible = not stats_visible
  set_stats_visible(stats_visible)
end)

sbar.add("event", "toggle_stats")
sbar.add("event", "hide_stats")
sbar.add("event", "show_stats")
sbar.add("event", "cpu_update")

separator:subscribe("toggle_stats", function(_)
  stats_visible = not stats_visible
  set_stats_visible(stats_visible)
end)

separator:subscribe("hide_stats", function(_)
  stats_visible = false
  set_stats_visible(false)
end)

separator:subscribe("show_stats", function(_)
  stats_visible = true
  set_stats_visible(true)
end)

-- Launch the CPU event provider (Mach API, near-zero overhead)
sbar.exec(
  "killall cpu_load >/dev/null 2>&1; $CONFIG_DIR/helpers/event_providers/cpu_load/bin/cpu_load cpu_update 2.0 &"
)

cpu:subscribe("cpu_update", function(env)
  if utils.is_sleeping then
    return
  end
  local total = tonumber(env.total_load) or 0
  local label_color = colors.fg
  if total > 80 then
    label_color = colors.red
  elseif total > 60 then
    label_color = colors.orange
  elseif total > 30 then
    label_color = colors.yellow
  end
  cpu:set({ label = { string = tostring(total) .. "%", color = label_color } })
end)

memory:subscribe({ "routine", "forced" }, function(_)
  if utils.is_sleeping then
    return
  end
  sbar.exec(
    "memory_pressure | grep -o 'System-wide memory free percentage: [0-9]*' | grep -o '[0-9]*'",
    function(result)
      local free = result and tonumber(result:match("%d+"))
      if free then
        memory:set({ label = { string = tostring(100 - free) .. "%" } })
      end
    end
  )
end)

disk:subscribe({ "routine", "forced" }, function(_)
  if utils.is_sleeping then
    return
  end
  sbar.exec("/bin/df -H /System/Volumes/Data | awk 'NR==2 {print $5}'", function(result)
    if result then
      disk:set({ label = { string = result:match("^%s*(.-)%s*$") } })
    end
  end)
end)

-- Network monitoring via nettop route-level stats (sysctl ifi_ibytes is 0 on corporate VPN setups).
-- NF-relative awk extraction: bytes_in is NF-8, bytes_out is NF-7.
local prev_net_in = nil
local prev_net_out = nil

local function format_rate(bps)
  if bps < 1000 then
    return string.format("%03d" .. "Bps", bps)
  elseif bps < 1000000 then
    return string.format("%03d" .. "KBps", math.floor(bps / 1000))
  else
    return string.format("%03d" .. "MBps", math.floor(bps / 1000000))
  end
end

net_down:set({ update_freq = 2, updates = "on" })
net_down:subscribe({ "routine", "forced" }, function(_)
  if utils.is_sleeping then
    return
  end
  sbar.exec(
    "nettop -m route -n -l 1 -P -x 2>/dev/null | awk '!/lo0/ && !/^time/ && NF>=9 {ib+=$(NF-8); ob+=$(NF-7)} END{printf \"%d %d\\n\", ib, ob}'",
    function(result)
      if not result then
        return
      end
      local ib, ob = result:match("(%d+)%s+(%d+)")
      ib = tonumber(ib)
      ob = tonumber(ob)
      if not ib or not ob then
        return
      end

      if prev_net_in then
        local dt = 2.0
        local down_rate = math.max(0, math.floor((ib - prev_net_in) / dt))
        local up_rate = math.max(0, math.floor((ob - prev_net_out) / dt))
        local down_str = format_rate(down_rate)
        local up_str = format_rate(up_rate)
        local down_idle = down_rate == 0
        local up_idle = up_rate == 0
        net_down:set({
          icon = { color = down_idle and colors.comment or colors.blue },
          label = { string = down_str },
        })
        net_up:set({
          icon = { color = up_idle and colors.comment or colors.green },
          label = { string = up_str },
        })
      end

      prev_net_in = ib
      prev_net_out = ob
    end
  )
end)
