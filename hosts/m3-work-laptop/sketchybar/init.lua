local sbar = require("sbar")
local utils = require("utils")

sbar.begin_config()
sbar.hotload(true)
require("bar")
require("default")
require("items")
sbar.end_config()

-- Sleep awareness: guard polling callbacks from firing during system sleep
local sleep_watcher = sbar.add("item", "sleep_watcher", {
  drawing = false,
  updates = "on",
})

sleep_watcher:subscribe("system_will_sleep", function()
  utils.is_sleeping = true
end)

sleep_watcher:subscribe("system_woke", function()
  utils.is_sleeping = false
  sbar.trigger("forced")
end)

sbar.event_loop()
