local colors = require("colors")
local icons = require("icons")
local settings = require("settings")
local sbar = require("sbar")

-- Grouped wifi + battery widget inside a bracket

local wifi = sbar.add("item", "wifi", {
  position = "right",
  update_freq = 30,
  icon = {
    string = icons.wifi.connected,
    color = colors.yellow,
    font = {
      family = settings.font.nerd,
      style = settings.font.style.regular,
      size = settings.icon_size,
    },
    y_offset = 1,
    padding_left = 8,
    padding_right = 2,
  },
  label = {
    string = "",
    color = colors.fg_dim,
    font = {
      family = settings.font.label,
      style = settings.font.style.medium,
      size = settings.label_size,
    },
    padding_left = 4,
    padding_right = 6,
  },
  background = { color = colors.transparent },
  padding_left = 0,
  padding_right = 0,
})

local battery = sbar.add("item", "battery", {
  position = "right",
  update_freq = 120,
  icon = {
    string = icons.battery._100,
    color = colors.green,
    font = {
      family = settings.font.nerd,
      style = settings.font.style.semibold,
      size = settings.icon_size,
    },
    y_offset = 1,
    padding_left = 6,
    padding_right = 2,
  },
  label = {
    string = "??%",
    color = colors.fg_dim,
    font = {
      family = settings.font.label,
      style = settings.font.style.medium,
      size = settings.label_size,
    },
    padding_right = 8,
  },
  background = { color = colors.transparent },
  padding_left = 0,
  padding_right = 0,
})

sbar.add("bracket", "net_bat", {
  wifi.name,
  battery.name,
}, {
  background = {
    color = colors.item_bg,
    height = settings.item_height,
    corner_radius = settings.item_radius,
  },
})

-- WiFi update

local function update_wifi()
  sbar.exec("networksetup -listpreferredwirelessnetworks en0 | sed -n '2 p' | tr -d '\\t'", function(ssid)
    ssid = ssid and ssid:match("^%s*(.-)%s*$") or ""

    sbar.exec("scutil --nwi | grep -m1 utun | awk '{ print $1 }'", function(vpn_result)
      local has_vpn = vpn_result and vpn_result:match("%S") ~= nil

      if has_vpn then
        wifi:set({
          icon = { string = icons.wifi.vpn, color = colors.teal },
          label = { string = ssid ~= "" and ssid or "VPN" },
        })
      elseif ssid ~= "" then
        wifi:set({
          icon = { string = icons.wifi.connected, color = colors.yellow },
          label = { string = ssid },
        })
      else
        wifi:set({
          icon = { string = icons.wifi.disconnected, color = colors.comment },
          label = { string = "No WiFi" },
        })
      end
    end)
  end)
end

wifi:subscribe({ "wifi_change", "system_woke", "routine", "forced" }, function(_)
  update_wifi()
end)

update_wifi()

-- Battery update

local function update_battery()
  sbar.exec("pmset -g batt", function(result)
    if not result then
      return
    end

    local is_charging = result:find("AC Power") ~= nil
    local percent = tonumber(result:match("(%d+)%%"))
    if not percent then
      return
    end

    local icon, icon_color
    if is_charging then
      icon = icons.battery.charging
      icon_color = colors.green
    elseif percent > 80 then
      icon = icons.battery._100
      icon_color = colors.green
    elseif percent > 60 then
      icon = icons.battery._75
      icon_color = colors.green
    elseif percent > 40 then
      icon = icons.battery._50
      icon_color = colors.yellow
    elseif percent > 20 then
      icon = icons.battery._25
      icon_color = colors.orange
    else
      icon = icons.battery._0
      icon_color = colors.red
    end

    battery:set({
      icon = { string = icon, color = icon_color },
      label = { string = tostring(percent) .. "%" },
    })
  end)
end

battery:subscribe({ "power_source_change", "system_woke", "routine", "forced" }, function(_)
  update_battery()
end)

update_battery()
