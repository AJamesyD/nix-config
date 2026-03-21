local M = {}

-- Fallback icons for apps not covered by sketchybar-app-font.
-- The font handles most apps natively via the `:AppName:` syntax,
-- so this module only needs to cover gaps.
local fallback_icons = {
  ["default"] = ":default:",
}

function M.get_icon(app_name)
  if not app_name or app_name == "" then
    return fallback_icons["default"]
  end
  return ":" .. app_name .. ":"
end

return M
