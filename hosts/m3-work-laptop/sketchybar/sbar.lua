-- Wrapper so modules can `require("sbar")` instead of the full module path
package.cpath = package.cpath .. ";/Users/" .. os.getenv("USER") .. "/.local/share/sketchybar_lua/?.so"

return require("sketchybar")
