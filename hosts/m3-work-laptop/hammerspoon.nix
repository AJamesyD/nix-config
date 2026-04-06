_: {
  launchd.agents.gym-nudge = {
    enable = true;
    config = {
      Label = "com.user.gym-nudge";
      ProgramArguments = [
        "/usr/bin/open"
        "-g"
        "hammerspoon://gym-nudge"
      ];
      StartCalendarInterval = [
        {
          Hour = 14;
          Minute = 45;
          Weekday = 1;
        }
        {
          Hour = 14;
          Minute = 45;
          Weekday = 3;
        }
        {
          Hour = 8;
          Minute = 0;
          Weekday = 5;
        }
      ];
    };
  };

  home.file.".hammerspoon/init.lua".text = ''
    local log_path = os.getenv("HOME") .. "/.local/share/gym-nudge/log.csv"

    hs.urlevent.bind("gym-nudge", function()
      local trigger_hour = tonumber(os.date("%H"))
      local trigger_min = tonumber(os.date("%M"))
      local scheduled_hour = (os.date("%w") == "5") and 8 or 14
      local scheduled_min = (os.date("%w") == "5") and 0 or 45
      local diff = (trigger_hour * 60 + trigger_min) - (scheduled_hour * 60 + scheduled_min)
      if diff > 180 then
        hs.notify.new({title = "Gym Nudge", informativeText = "Skipped (stale trigger)"}):send()
        return
      end

      local function log_response(resp)
        os.execute("mkdir -p '" .. os.getenv("HOME") .. "/.local/share/gym-nudge'")
        local f = io.open(log_path, "a")
        if f then
          f:write(os.date("%Y-%m-%d") .. "," .. os.date("%A") .. "," .. resp .. "\n")
          f:close()
        end
      end

      local result = hs.dialog.blockAlert("Gym Day!", "Close all apps and head to the gym in 5 minutes?", "Let's go", "Not today")
      if result == "Let's go" then
        local _delay = hs.timer.doAfter(300, function()
          for _, app in ipairs(hs.application.runningApplications()) do
            if app:bundleID() ~= "org.hammerspoon.Hammerspoon" and app:bundleID() ~= "com.apple.finder" then
              app:kill()
            end
          end

          local _checkinDelay = hs.timer.doAfter(2, function()
            local checkin = hs.dialog.blockAlert("Gym Check-in", "Did you go to the gym?", "Yes", "No")
            local response
            if checkin == "Yes" then
              response = "yes"
            elseif hs.dialog.blockAlert("Skip?", "Planning to skip today?", "Skipping", "No, just not yet") == "Skipping" then
              response = "skipping"
            else
              response = "no"
            end
            log_response(response)
          end)
        end)
      else
        log_response("declined")
      end
    end)
  '';
}
