{
  description = "My nix configuration(s)";

  nixConfig = {
    extra-trusted-substituters = [
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    devenv = {
      url = "github:cachix/devenv";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-compat.follows = "flake-compat";
        git-hooks.follows = "git-hooks-nix";
      };
    };
    flake-compat.url = "https://flakehub.com/f/edolstra/flake-compat/1.tar.gz";
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.systems.follows = "systems";
    };
    git-hooks-nix = {
      url = "github:cachix/git-hooks.nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-compat.follows = "flake-compat";
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
        treefmt-nix.follows = "flake-parts";
      };
    };
    systems.url = "github:nix-systems/default";
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
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

        debug = true; # This exposes declarations for nixd lsp

        systems = [
          "aarch64-darwin"
          "aarch64-linux"
          "x86_64-linux"
        ];

        flake = {
          hosts = import ./nix/hosts.nix;

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
                    "users/angaidan/.config/sketchybar/plugins/*"
                    "users/angaidan/.config/sketchybar/*"
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
