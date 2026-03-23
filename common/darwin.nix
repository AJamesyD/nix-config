{
  self,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./nix-sys.nix
  ];

  documentation = {
    enable = true;
    doc.enable = true;
    info.enable = true;
    man.enable = true;
  };

  environment = {
    enableAllTerminfo = true;
    extraSetup = # bash
      ''
        ln -sv ${pkgs.path} $out/nixpkgs
      '';
    pathsToLink = [
      "/share/bash-completion"
      "/share/zsh"
    ];
    shells = with pkgs; [
      bashInteractive
      zsh
    ];
    systemPackages =
      with pkgs;
      [
        libplist
        openssh
        vim
      ]
      ++ map (x: x.terminfo) (
        with pkgs.pkgsBuildBuild;
        [
          alacritty
        ]
      );
    systemPath = lib.mkBefore [
      "/opt/homebrew/bin"
      "/opt/homebrew/sbin"
    ];
    variables = {
      EDITOR = "nvim";
      HOMEBREW_NO_ANALYTICS = "1";
      SHELL = lib.getExe pkgs.zsh;
    };
  };

  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      cleanup = "zap";
      upgrade = true;
    };
    taps = [
      {
        name = "homebrew/services";
      }
    ];
    brews = [
    ];
    casks = [
      {
        name = "karabiner-elements";
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
        args = {
          no_quarantine = true;
        };
      }
      {
        name = "zoom";
        greedy = true;
      }
    ];
  };

  home-manager = {
    backupFileExtension = "bak";
    useGlobalPkgs = true;
    useUserPackages = true;
  };

  # Create /etc/zshrc that loads the nix-darwin environment.
  programs.zsh = {
    enable = true; # default shell on catalina
    # XXX: Disable completion in favor of home-manager setup
    enableBashCompletion = false;
    enableCompletion = false;
  };

  # Enable sudo authentication with Touch ID.
  security = {
    pam.services = {
      sudo_local = {
        reattach = true;
        touchIdAuth = true;
      };
    };
    sudo.extraConfig = # bash
      ''
        Defaults timestamp_timeout = 2
      '';
  };

  system = {
    # Set Git commit hash for darwin-version.
    configurationRevision = self.rev or self.dirtyRev or null;

    defaults = {
      ".GlobalPreferences" = {
        "com.apple.mouse.scaling" = 2.0;
        "com.apple.sound.beep.sound" = "/System/Library/Sounds/Blow.aiff";
      };
      CustomUserPreferences = {
        # Disable macOS hotkeys that conflict with Aerospace, Raycast, or are
        # redundant when using a tiling WM.
        #
        # WARNING: defaults write replaces the entire AppleSymbolicHotKeys dict.
        # Any key not listed here resets to macOS defaults on rebuild.
        #
        # Source: Apple's DefaultShortcutsTable.xml
        #   /System/Library/ExtensionKit/Extensions/KeyboardSettings.appex/
        #     Contents/Resources/en.lproj/DefaultShortcutsTable.xml
        # Reference: https://github.com/andyjakubowski/dotfiles/blob/main/AppleSymbolicHotKeys%20Mappings
        # Verify: defaults read com.apple.symbolichotkeys AppleSymbolicHotKeys
        # GUI: System Settings > Keyboard > Keyboard Shortcuts
        "com.apple.symbolichotkeys" = {
          AppleSymbolicHotKeys = {
            # === Screenshots ===
            # Disabled: Cmd+Shift+3/4/5/6 conflict with Aerospace workspace numbers.
            # Use Raycast or Cmd+Shift+5 (if re-enabled) for screenshots.

            # 28: Save picture of screen as a file (Cmd+Shift+3)
            "28" = {
              enabled = false;
            };
            # 29: Copy picture of screen to the clipboard (Cmd+Ctrl+Shift+3)
            "29" = {
              enabled = false;
            };
            # 30: Save picture of selected area as a file (Cmd+Shift+4)
            "30" = {
              enabled = false;
            };
            # 31: Copy picture of selected area to the clipboard (Cmd+Ctrl+Shift+4)
            "31" = {
              enabled = false;
            };
            # 181: Save picture of the Touch Bar as a file (Cmd+Shift+6)
            # No Touch Bar on M3, but macOS may still intercept Cmd+Shift+6.
            "181" = {
              enabled = false;
            };
            # 182: Copy picture of the Touch Bar to the clipboard (Cmd+Ctrl+Shift+6)
            "182" = {
              enabled = false;
            };
            # 184: Screenshot and recording options (Cmd+Shift+5)
            "184" = {
              enabled = false;
            };

            # === Spotlight ===
            # Disabled: Raycast replaces Spotlight on Cmd+Space.

            # 64: Show Spotlight search (Cmd+Space)
            "64" = {
              enabled = false;
            };
            # 65: Show Finder search window (Cmd+Option+Space)
            "65" = {
              enabled = false;
            };

            # === Mission Control / Spaces ===
            # Disabled: Aerospace manages workspaces; these intercept Ctrl+arrows
            # before Aerospace sees them.

            # 32: Mission Control / All windows (Ctrl+Up)
            "32" = {
              enabled = false;
            };
            # 34: Mission Control / All windows (slow key variant) (Ctrl+Up)
            "34" = {
              enabled = false;
            };
            # 33: Application windows / App Expose (Ctrl+Down)
            "33" = {
              enabled = false;
            };
            # 35: Application windows (slow key variant) (Ctrl+Down)
            "35" = {
              enabled = false;
            };
            # 36: Show Desktop (F11)
            "36" = {
              enabled = false;
            };
            # 37: Show Desktop (slow key variant) (F11)
            "37" = {
              enabled = false;
            };
            # 79: Move to previous Space (Ctrl+Left)
            "79" = {
              enabled = false;
            };
            # 80: Move to previous Space (slow key variant) (Ctrl+Left)
            "80" = {
              enabled = false;
            };
            # 81: Move to next Space (Ctrl+Right)
            "81" = {
              enabled = false;
            };
            # 82: Move to next Space (slow key variant) (Ctrl+Right)
            "82" = {
              enabled = false;
            };

            # === Window Tiling (macOS Sequoia+) ===
            # Disabled: Aerospace handles all window tiling. These Globe+Ctrl
            # shortcuts would conflict or cause confusion.

            # 237: Fill (Globe+Ctrl+f)
            "237" = {
              enabled = false;
            };
            # 238: Center (Globe+Ctrl+c)
            "238" = {
              enabled = false;
            };
            # 239: Return to previous size (Globe+Ctrl+r)
            "239" = {
              enabled = false;
            };
            # 240: Tile left half (Globe+Ctrl+Left)
            "240" = {
              enabled = false;
            };
            # 241: Tile right half (Globe+Ctrl+Right)
            "241" = {
              enabled = false;
            };
            # 242: Tile top half (Globe+Ctrl+Up)
            "242" = {
              enabled = false;
            };
            # 243: Tile bottom half (Globe+Ctrl+Down)
            "243" = {
              enabled = false;
            };
            # 248: Arrange left and right (Globe+Ctrl+Shift+Left)
            "248" = {
              enabled = false;
            };
            # 249: Arrange right and left (Globe+Ctrl+Shift+Right)
            "249" = {
              enabled = false;
            };
            # 250: Arrange top and bottom (Globe+Ctrl+Shift+Up)
            "250" = {
              enabled = false;
            };
            # 251: Arrange bottom and top (Globe+Ctrl+Shift+Down)
            "251" = {
              enabled = false;
            };
          };
        };
        "com.apple.controlcenter" = {
          BatteryShowPercentage = true;
        };
        "com.apple.dock" = {
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
          AppleWindowTabbingMode = "always";
          InitialKeyRepeat = 10;
          KeyRepeat = 2;
          "com.apple.sound.uiaudio.enabled" = false;
          _HIHideMenuBar = true;
        };
      };
      NSGlobalDomain = {
        AppleEnableMouseSwipeNavigateWithScrolls = false;
        AppleEnableSwipeNavigateWithScrolls = false;
        AppleInterfaceStyle = "Dark";
        AppleShowAllExtensions = true;
        AppleShowAllFiles = true;
        AppleShowScrollBars = "WhenScrolling";
        InitialKeyRepeat = 25;
        KeyRepeat = 2;
        NSAutomaticDashSubstitutionEnabled = false;
        NSAutomaticQuoteSubstitutionEnabled = false;
        NSAutomaticWindowAnimationsEnabled = false;
        NSWindowResizeTime = 1.0e-2;
        "com.apple.keyboard.fnState" = false;
        "com.apple.sound.beep.feedback" = 1;
        "com.apple.sound.beep.volume" = 0.5;
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
        expose-group-apps = true;
        largesize = 128;
        launchanim = false;
        magnification = true;
        mineffect = "scale";
        minimize-to-application = true;
        mru-spaces = false;
        orientation = "left";
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
        # This is for AeroSpace and SketchyBar
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

    startup.chime = false;
  };
}
