local colors = require("colors")
local icons = require("icons")
local settings = require("settings")
local sbar = require("sbar")

local space = sbar.add("item", "aerospace", {
  position = "left",
  icon = {
    string = icons.aerospace.default,
    font = {
      family = settings.font.nerd,
      style = settings.font.style.bold,
      size = settings.icon_size,
    },
    color = colors.fg,
    y_offset = 1,
    padding_left = 6,
    padding_right = 6,
  },
  label = { drawing = false },
  background = {
    color = colors.blue,
    corner_radius = settings.item_radius,
    height = settings.item_height,
  },
  padding_left = 6,
  padding_right = 6,
})

local function update_workspace(workspace_name)
  if not workspace_name or workspace_name == "" then
    return
  end
  workspace_name = workspace_name:match("^%s*(.-)%s*$")
  if workspace_name == "" then
    return
  end
  local icon = icons.aerospace[workspace_name] or icons.aerospace.default
  space:set({
    icon = { string = icon },
  })
end

sbar.add("event", "aerospace_workspace_change")

space:subscribe("aerospace_workspace_change", function(env)
  update_workspace(env.AEROSPACE_FOCUSED_WORKSPACE)
end)

-- Retry startup query: AeroSpace may still be starting when sketchybar loads
local retry_count = 0
local function try_get_workspace()
  sbar.exec("aerospace list-workspaces --focused 2>/dev/null", function(result)
    result = result and result:match("^%s*(.-)%s*$") or ""
    if result ~= "" then
      update_workspace(result)
    elseif retry_count < 5 then
      retry_count = retry_count + 1
      sbar.exec("sleep 2 && aerospace list-workspaces --focused 2>/dev/null", function(r)
        r = r and r:match("^%s*(.-)%s*$") or ""
        if r ~= "" then
          update_workspace(r)
        elseif retry_count < 5 then
          retry_count = retry_count + 1
          try_get_workspace()
        end
      end)
    end
  end)
end

try_get_workspace()
