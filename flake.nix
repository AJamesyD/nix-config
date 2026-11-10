{
  description = "My nix configuration(s)";

  nixConfig = rec {
    extra-substituters = [
      "https://ajamesyd-nix-cache.cachix.org?priority=1"
      "https://nix-community.cachix.org?priority=2"
    ];
    extra-trusted-substituters = extra-substituters;
    extra-trusted-public-keys = [
      "ajamesyd-nix-cache.cachix.org-1:Y0fyrCv5xarnB+awDmggLF6RL3RJtyxBDRjXo7xlsVw="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    # HACK: pinned to last rev before workspace.nix added libghostty-vt dep
    #   which breaks flakes integration (callPackageWith missing arg).
    #   Unpin once cachix/devenv ships a fix. Test: `nix eval .#devShells.aarch64-darwin.default`
    #   with the pin removed.
    devenv = {
      url = "github:cachix/devenv/046cd4c44e27cace2fdca06e2096d32597ebf9d2";
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
    kanata-darwin = {
      url = "github:not-in-stock/kanata-darwin";
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
    # TODO: Pin the `stable` channel and add `inputs.nixpkgs.follows` once Rex
    #   is GA. Today the flake has only `snapshot` and no nixpkgs input.
    rex.url = "https://pkgs.superlogical.com/rex/nix/snapshot.tar.gz";
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
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };
    llm-agents = {
      url = "github:numtide/llm-agents.nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
        treefmt-nix.follows = "treefmt-nix";
      };
    };
    amzn-community = {
      url = "git+ssh://git.amazon.com:2222/pkg/AmznNix-Community";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zig-overlay = {
      url = "github:mitchellh/zig-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
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
            packages.bootstrap = pkgs.writeShellApplication {
              name = "bootstrap";
              runtimeInputs = [ pkgs.coreutils ];
              text = ''
                key_dir="$HOME/.config/sops/age"
                key_file="$key_dir/keys.txt"

                if [ -f "$key_file" ]; then
                  echo "Key already exists at $key_file"
                  exit 0
                fi

                mkdir -p "$key_dir"
                echo "Paste your age secret key (starts with AGE-SECRET-KEY-), then press Enter:"
                read -r key

                if [[ ! "$key" =~ ^AGE-SECRET-KEY- ]]; then
                  echo "Error: invalid age secret key format" >&2
                  exit 1
                fi

                echo "$key" > "$key_file"
                chmod 600 "$key_file"
                echo "Key written to $key_file"
              '';
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
                sops
                age
              ];
              env.SOPS_AGE_KEY_FILE = "$HOME/.config/sops/age/keys.txt";
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
                  eval-hosts = {
                    enable = true;
                    name = "evaluate host configurations";
                    entry = "bash ci/eval-hosts.sh";
                    # NOTE: pre-push only. A full eval of every host takes about a
                    #   minute, too slow for pre-commit. always_run because a
                    #   flake.lock bump (not just a .nix edit) can break evaluation,
                    #   so file-based filtering would miss it.
                    stages = [ "pre-push" ];
                    always_run = true;
                    pass_filenames = false;
                  };
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
                    "repeated_keys" # W20: intentional split of home.*/launchd.* into per-concern blocks
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
