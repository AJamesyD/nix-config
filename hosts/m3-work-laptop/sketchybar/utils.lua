local sbar = require("sbar")

local M = {}

function M.popup_toggle(item_name)
  sbar.set(item_name, { popup = { drawing = "toggle" } })
end

function M.shell_quote(str)
  if not str then
    return "''"
  end
  return "'" .. str:gsub("'", "'\\''") .. "'"
end

function M.is_empty(str)
  return str == nil or str == ""
end

function M.str_split(str, sep)
  local parts = {}
  if not str then
    return parts
  end
  local pattern = sep and ("[^" .. sep .. "]+") or "%S+"
  for part in str:gmatch(pattern) do
    parts[#parts + 1] = part
  end
  return parts
end

function M.trim(str)
  if not str then
    return ""
  end
  return str:match("^%s*(.-)%s*$") or ""
end

M.is_sleeping = false

return M
