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
    git-hooks = {
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
          inputs.git-hooks.flakeModule
          inputs.treefmt-nix.flakeModule
        ];
        systems = [
          "aarch64-darwin"
          "aarch64-linux"
          "x86_64-linux"
        ];
        perSystem =
          ctx@{
            config,
            self',
            inputs',
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

            devShells = import ./nix/dev-shell.nix ctx;

            packages = import ./nix/packages.nix toplevel ctx;

            pre-commit = {
              settings.hooks = {
                nil.enable = true;
                shellcheck.enable = true;
                statix.enable = true;
                treefmt.enable = true;
                trim-trailing-whitespace.enable = true;
              };
            };

            treefmt = {
              projectRootFile = "flake.nix";
              programs = {
                nixfmt.enable = true;
                shfmt = {
                  enable = true;
                  indent_size = 0;
                };
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
