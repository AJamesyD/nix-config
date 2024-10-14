{ withSystem, inputs, ... }:
let
  inherit (inputs) self home-manager nixpkgs;
  inherit (nixpkgs) lib;

  genModules =
    hostName:
    { homeDirectory, username, ... }:
    { config, pkgs, ... }:
    {
      imports = [ (../hosts + "/${hostName}") ];

      home =
        {
          inherit homeDirectory;
          inherit username;

          packages = with pkgs; [
            # For terminfo definitions
            (lib.hiPrio ncurses)
          ];

          sessionVariables = {
            # NOTE: May have to chmod +x -R terminfo definitions (not sure why)
            TERMINFO_DIRS = "${config.home.profileDirectory}/share/terminfo:/etc/terminfo:/lib/terminfo:/usr/share/terminfo";
          };
        }
        // lib.optionalAttrs (config.programs.zsh.dotDir != null) {
          # When dotDir is set, still create ~/.zshrc so that it is write-protected against
          # random programs trying to append to it
          file = {
            ".zshrc" = {
              text = # bash
                ''
                  # This file is intentionally empty.

                  # When dotDir is set, still create ~/.zshrc so that it is write-protected against
                  # random programs trying to append to it
                '';
            };
          };
        };

      nix = {
        enable = true;
        package = pkgs.nixVersions.latest;
        registry = {
          nixpkgs.flake = nixpkgs;
          p.flake = nixpkgs;
        };
        settings = {
          flake-registry = "${config.xdg.configHome}/nix/registry.json";
          trusted-users = [ username ];
        };
      };

      programs = {
        home-manager = {
          enable = true;
        };
      };

      targets.genericLinux.enable = true;

      xdg = {
        enable = true;
        dataFile.nixpkgs.source = nixpkgs;
      };
    };

  genConfiguration =
    hostName:
    { hostPlatform, type, ... }@attrs:
    withSystem hostPlatform (
      { pkgs, ... }:
      home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [ (genModules hostName attrs) ];
        extraSpecialArgs = {
          hostType = type;
          inherit (inputs)
            nix-index-database
            ;
        };
      }
    );
in
lib.mapAttrs genConfiguration (lib.filterAttrs (_: host: host.type == "home-manager") self.hosts)
