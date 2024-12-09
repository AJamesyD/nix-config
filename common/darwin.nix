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
        coreutils
        findutils
        gawk
        git
        git-lfs
        gnugrep
        gnused
        gnutar
        gnutls
        libplist
        # required to make terminfo files available before zsh login
        (lib.hiPrio ncurses)
        neofetch
        pandoc
        rsync
        squashfsTools

        openssh

        (luajit.withPackages (
          ps: with ps; [
            luarocks
            luv
          ]
        ))
        neovim
        vim
      ]
      ++ map (x: x.terminfo) (
        with pkgs.pkgsBuildBuild;
        [
          alacritty
          kitty
          rio
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
      }
      {
        name = "zoom";
        greedy = true;
      }
    ];
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
  };

  # Create /etc/zshrc that loads the nix-darwin environment.
  programs.zsh.enable = true; # default shell on catalina

  # Enable sudo authentication with Touch ID.
  security = {
    pam.enableSudoTouchIdAuth = true;
    sudo.extraConfig = # bash
      ''
        Defaults timestamp_timeout = 2
      '';
  };

  services = {
    # Auto upgrade nix package and the daemon service.
    nix-daemon.enable = true;
  };

  system = {
    # TODO: Borrow https://github.com/IvarWithoutBones/dotfiles/commit/0b3faad8bd1d0e1af6103caf59b206666ab742f4
    # so Applications folders linked properly

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

    startup.chime = false;
  };
}
