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
      local now = os.time()
      local trigger_hour = tonumber(os.date("%H"))
      local trigger_min = tonumber(os.date("%M"))
      local scheduled_hour = (os.date("%w") == "5") and 8 or 14
      local scheduled_min = 45
      local diff = (trigger_hour * 60 + trigger_min) - (scheduled_hour * 60 + scheduled_min)
      if diff > 180 then
        hs.notify.new({title = "Gym Nudge", informativeText = "Skipped (stale trigger)"}):send()
        return
      end

      local result = hs.dialog.blockingAlert("Gym Day!", "Close all apps and head to the gym in 5 minutes?", "Let's go", "Not today")
      if result == "Let's go" then
        hs.timer.doAfter(300, function()
          for _, app in ipairs(hs.application.runningApplications()) do
            if app:bundleID() ~= "org.hammerspoon.Hammerspoon" and app:bundleID() ~= "com.apple.finder" then
              app:kill()
            end
          end

          hs.timer.doAfter(2, function()
            local checkin = hs.dialog.blockingAlert("Gym Check-in", "Have you gone to the gym?", "Yes", "No", "Skipping")
            local response = (checkin == "Yes") and "yes" or (checkin == "No") and "no" or "skipping"
            os.execute("mkdir -p " .. os.getenv("HOME") .. "/.local/share/gym-nudge")
            local f = io.open(log_path, "a")
            if f then
              f:write(os.date("%Y-%m-%d") .. "," .. os.date("%A") .. "," .. response .. "\n")
              f:close()
            end
          end)
        end)
      else
        os.execute("mkdir -p " .. os.getenv("HOME") .. "/.local/share/gym-nudge")
        local f = io.open(log_path, "a")
        if f then
          f:write(os.date("%Y-%m-%d") .. "," .. os.date("%A") .. ",declined" .. "\n")
          f:close()
        end
      end
    end)
  '';
}
