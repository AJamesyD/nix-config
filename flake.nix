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
    devenv-root = {
      url = "file+file:///dev/null";
      flake = false;
    };
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
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
        treefmt-nix.follows = "treefmt-nix";
      };
    };
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
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
    # No nixpkgs.follows: mac-app-util pins its own nixpkgs to a commit with
    # SBCL 2.4.10. Our nixpkgs has SBCL 2.6.x which breaks named-readtables,
    # causing fare-quasiquote build failures.
    # https://github.com/hraban/mac-app-util/issues/42
    mac-app-util = {
      url = "github:hraban/mac-app-util";
    };
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:nix-community/stylix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
      };
    };
    tmux-which-key = {
      url = "github:alexwforsythe/tmux-which-key/1f419775caf136a60aac8e3a269b51ad10b51eb6";
      flake = false;
    };
    tmux-resurrect = {
      url = "github:tmux-plugins/tmux-resurrect/cff343cf9e81983d3da0c8562b01616f12e8d548";
      flake = false;
    };
    tmux-continuum = {
      url = "github:tmux-plugins/tmux-continuum/0698e8f4b17d6454c71bf5212895ec055c578da0";
      flake = false;
    };
    tmux-fzf = {
      url = "github:sainnhe/tmux-fzf/05af76daa2487575b93a4f604693b00969f19c2f";
      flake = false;
    };
    catppuccin-tmux = {
      url = "github:catppuccin/tmux/8b0b9150f9d7dee2a4b70cdb50876ba7fd6d674a";
      flake = false;
    };
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };
  };

  outputs =
    inputs@{ self, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } (
      toplevel@{ withSystem, ... }:
      {
        imports = [
          ./nix/overlays.nix
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
              # devenv manages .pre-commit-config.yaml as a symlink to a nix store path.
              # A race condition (git-hooks.nix #685) can replace the symlink with a
              # regular file, breaking GC protection. .envrc auto-detects and removes
              # the broken file; keep-outputs in nix.settings prevents most GC breakage.
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
                shellcheck.enable = true;
                shfmt = {
                  enable = true;
                  indent_size = 0;
                };
                statix = {
                  enable = true;
                  disabled-lints = [
                    "collapsible_let_in" # W06: false positive with shadowed bindings
                    "bool_simplification" # W18: wrong when comparing non-bool values
                    "manual_inherit_from" # W04: wrong with `or` fallback
                  ];
                };
                stylua = {
                  enable = true;
                  settings = {
                    column_width = 120;
                    line_endings = "Unix";
                    indent_type = "Spaces";
                    indent_width = 2;
                    quote_style = "AutoPreferDouble";
                    call_parentheses = "Always";
                  };
                };
                taplo.enable = true;
              };
            };
          };
      }
    );
}
