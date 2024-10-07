{
  description = "My nix configuration(s)";

  nixConfig = {
    extra-trusted-substituters = [
      "https://nix-config.cachix.org"
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-config.cachix.org-1:Vd6raEuldeIZpttVQfrUbLvXJHzzzkS0pezXCVVjDG4="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  inputs = {
    devenv = {
      url = "github:cachix/devenv";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.systems.follows = "systems";
    };
    git-hooks-nix = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-fast-build = {
      url = "github:Mic92/nix-fast-build";
      inputs = {
        flake-parts.follows = "flake-parts";
        nixpkgs.follows = "nixpkgs";
      };
    };
    nix-index-database = {
      url = "github:Mic92/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
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
        systems = [
          "aarch64-darwin"
          "aarch64-linux"
          "x86_64-linux"
        ];
        perSystem =
          {
            config,
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
                nix-fast-build
                nix-output-monitor
                nix-tree
              ];
              pre-commit = {
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
                shellcheck.enable = true;
                shfmt = {
                  enable = true;
                  indent_size = 0;
                };
                statix.enable = true;
                taplo.enable = true;
              };
            };
          };

        flake = {
          hosts = import ./nix/hosts.nix;

          darwinConfigurations = import ./nix/darwin-configuration.nix toplevel;
          homeConfigurations = import ./nix/home-configuration.nix toplevel;
        };
      }
    );
}
