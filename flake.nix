{
  description = "My nix configuration(s)";

  nixConfig = rec {
    extra-substituters = [
      "https://nix-config.cachix.org?priority=1"
      "https://nix-community.cachix.org?priority=2"
    ];
    extra-trusted-substituters = extra-substituters;
    extra-trusted-public-keys = [
      "nix-config.cachix.org-1:Vd6raEuldeIZpttVQfrUbLvXJHzzzkS0pezXCVVjDG4="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    devenv = {
      url = "github:cachix/devenv";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        git-hooks.follows = "git-hooks-nix";
      };
    };
    direnv-instant = {
      url = "github:Mic92/direnv-instant";
    };
    flake-parts.url = "github:hercules-ci/flake-parts";
    git-hooks-nix = {
      url = "github:cachix/git-hooks.nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixd = {
      url = "github:nix-community/nixd";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
        treefmt-nix.follows = "treefmt-nix";
      };
    };
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-fast-build = {
      url = "github:Mic92/nix-fast-build";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
        treefmt-nix.follows = "treefmt-nix";
      };
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    tokyonight-nvim = {
      url = "github:folke/tokyonight.nvim/v4.8.0";
      flake = false;
    };
    tmux-which-key = {
      url = "github:alexwforsythe/tmux-which-key/1f419775caf136a60aac8e3a269b51ad10b51eb6";
      flake = false;
    };
    zsh-auto-notify = {
      url = "github:MichaelAquilina/zsh-auto-notify/27c07dddb42f05b199319a9b66473c8de7935856";
      flake = false;
    };
    catppuccin-tmux = {
      url = "github:catppuccin/tmux/v2.1.2";
      flake = false;
    };
  };

  outputs =
    inputs@{ self, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } (
      toplevel@{ withSystem, ... }:
      {
        imports = [
          inputs.devenv.flakeModule
          inputs.git-hooks-nix.flakeModule
          inputs.treefmt-nix.flakeModule
        ];

        # Exposes debug/allSystems/currentSystem attrs for nix repl and nixd LSP
        debug = true;

        systems = [
          "aarch64-darwin"
          "aarch64-linux"
          "x86_64-linux"
        ];

        flake = {
          hosts = import ./nix/hosts.nix { inherit (inputs.nixpkgs) lib; };

          darwinConfigurations = import ./nix/darwin-configuration.nix toplevel;
          homeConfigurations = import ./nix/home-configuration.nix toplevel;
        };

        perSystem =
          {
            config,
            inputs',
            lib,
            pkgs,
            system,
            ...
          }:
          {
            _module.args.pkgs = import inputs.nixpkgs {
              config = {
                allowUnfree = true;
                allowAliases = true;
              };
              localSystem = system;
            };

            devenv.shells.default = {
              name = "nix-config";
              languages = {
                nix.enable = true;
              };
              packages = with pkgs; [
                # Nix
                cachix
                nixd
                nix-fast-build
                nix-output-monitor
                nix-tree
              ];
              git-hooks = {
                default_stages = [
                  "pre-commit"
                  "post-rewrite"
                ];
                hooks = {
                  check-added-large-files.enable = true;
                  check-json.enable = true;
                  check-merge-conflicts.enable = true;
                  check-shebang-scripts-are-executable.enable = true;
                  check-toml.enable = true;
                  end-of-file-fixer.enable = true;
                  nil.enable = true;
                  treefmt = {
                    enable = true;
                    always_run = true;
                    package = config.treefmt.build.wrapper;
                  };
                  trim-trailing-whitespace.enable = true;
                };
                inherit (config.pre-commit.settings) run;
              };
            };

            treefmt = {
              projectRootFile = "flake.nix";
              programs = {
                deadnix = {
                  enable = true;
                  no-lambda-arg = true;
                  no-lambda-pattern-names = true;
                  no-underscore = true;
                };
                jsonfmt.enable = true;
                nixfmt.enable = true;
                shellcheck = {
                  enable = true;
                  excludes = [
                    "hosts/m3-work-laptop/sketchybar/**/*"
                  ];
                };
                shfmt = {
                  enable = true;
                  indent_size = 0;
                };
                statix.enable = true;
                taplo.enable = true;
              };
            };
          };
      }
    );
}
