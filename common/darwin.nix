{
  self,
  home-manager,
  pkgs,
  ...
}:
{
  imports = [
    home-manager.darwinModules.home-manager
  ];

  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      cleanup = "zap";
      upgrade = true;
    };
    taps = [
      {
        name = "amazon/homebrew-amazon";
        clone_target = "ssh://git.amazon.com/pkg/HomebrewAmazon";
        force_auto_update = true;
      }
      {
        name = "caarlos0/tap";
      }
      {
        name = "homebrew/services";
      }
      {
        name = "nikitabobko/tap";
      }
    ];
    brews = [
      {
        name = "xdg-open-svc";
        restart_service = "changed";
        start_service = true;
      }
    ];
    casks = [
      {
        name = "aerospace";
        greedy = true;
      }
      {
        name = "amazon-acronyms";
        greedy = true;
      }
      {
        name = "obsidian";
        greedy = true;
      }
      {
        name = "raycast";
        greedy = true;
      }
      {
        name = "spotify";
        greedy = true;
      }
      {
        name = "xquartz";
        greedy = true;
      }
      {
        name = "zoom";
        greedy = true;
      }
      {
        name = "zulip";
        greedy = true;
      }
    ];
  };

  # TODO: Is this safe to change?
  # networking.hostName = "80a99738471f";

  nix = {
    gc = {
      automatic = true;
      interval = {
        # Friday
        Weekday = 5;
        Hour = 12;
        Minute = 0;
      };
      options = "--delete-older-than 28";
    };

    optimise = {
      automatic = true;
      interval = {
        Hour = 12;
        Minute = 0;
      };
    };
  };

  # Create /etc/zshrc that loads the nix-darwin environment.
  programs.zsh.enable = true; # default shell on catalina

  # Enable sudo authentication with Touch ID.
  security = {
    pam.enableSudoTouchIdAuth = true;
    sudo.extraConfig = ''
      Defaults timestamp_timeout = 2
    '';
  };

  services = {
    jankyborders = {
      enable = true;
      active_color = "0xffe1e3e4";
      inactive_color = "0xff494d64";
      hidpi = true;
      width = 7.5;
    };
    # Auto upgrade nix package and the daemon service.
    nix-daemon.enable = true;
  };

  system = {
    # Set Git commit hash for darwin-version.
    configurationRevision = self.rev or self.dirtyRev or null;

    defaults = {
      ".GlobalPreferences" = {
        "com.apple.mouse.scaling" = 2.0;
      };
      CustomUserPreferences = {
        "com.apple.controlcenter" = {
          BatteryShowPercentage = true;
        };
        "com.apple.dock" = {
          expose-group-apps = true;
          springboard-hide-duration = 1.0e-2;
          springboard-page-duration = 1.0e-2;
          springboard-show-duration = 1.0e-2;
        };
        "com.apple.finder" = {
          DisableAllAnimations = false;
          FXRemoveOldTrashItems = true;
          _FXSortFoldersFirst = true;
        };
        NSGlobalDomain = {
          AppleMenuBarVisibleInFullscreen = false;
          "com.apple.sound.uiaudio.enabled" = false;
        };
      };
      NSGlobalDomain = {
        AppleShowAllFiles = true;
        AppleEnableMouseSwipeNavigateWithScrolls = false;
        AppleEnableSwipeNavigateWithScrolls = false;
        AppleInterfaceStyle = "Dark";
        AppleShowAllExtensions = true;
        AppleShowScrollBars = "WhenScrolling";
        InitialKeyRepeat = 25;
        KeyRepeat = 2;
        NSAutomaticDashSubstitutionEnabled = false;
        NSAutomaticQuoteSubstitutionEnabled = false;
        NSAutomaticWindowAnimationsEnabled = false;
        NSWindowResizeTime = 1.0e-2;
        "com.apple.keyboard.fnState" = false;
        "com.apple.sound.beep.feedback" = 1;
        "com.apple.sound.beep.volume" = 1.0;
        "com.apple.trackpad.scaling" = 2.0;
      };
      SoftwareUpdate.AutomaticallyInstallMacOSUpdates = true;
      WindowManager = {
        AppWindowGroupingBehavior = true;
        AutoHide = true;
        EnableStandardClickToShowDesktop = false;
      };
      dock = {
        appswitcher-all-displays = true;
        autohide = true;
        autohide-delay = 1.0e-2;
        autohide-time-modifier = 1.0e-2;
        dashboard-in-overlay = true;
        expose-animation-duration = 1.0e-2;
        expose-group-by-app = true;
        largesize = 128;
        launchanim = false;
        magnification = true;
        mineffect = "scale";
        minimize-to-application = true;
        mru-spaces = false;
        orientation = "left";
        persistent-apps = [
          "Applications/Microsoft Outlook.app"
          "Applications/Amazon Chime.app"
          "Applications/Slack.app"
          "${pkgs.alacritty}/Applications/Alacritty.app"
        ];
        show-recents = false;
        tilesize = 64;
        wvous-bl-corner = 1;
        wvous-br-corner = 1;
        wvous-tl-corner = 1;
        wvous-tr-corner = 1;
      };
      finder = {
        AppleShowAllExtensions = true;
        AppleShowAllFiles = true;
        ShowPathbar = true;
        QuitMenuItem = true;
      };
      loginwindow = {
        SHOWFULLNAME = false;
      };
      spaces = {
        # This is for AeroSpace
        spans-displays = true;
      };
      universalaccess = {
        reduceMotion = true;
      };
    };

    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToEscape = true;
    };

    # Used for backwards compatibility, please read the changelog before changing.
    # $ darwin-rebuild changelog
    stateVersion = 5;

    startup.chime = false;
  };

  # Declare the user that will be running `nix-darwin`.
  users.users.angaidan = {
    name = "angaidan";
    home = "/Users/angaidan";
  };
}
