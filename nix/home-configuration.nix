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

      home = {
        inherit homeDirectory;
        inherit username;
        packages = with pkgs; [
          ncurses
        ];
      };

      nix.registry = {
        nixpkgs.flake = nixpkgs;
        p.flake = nixpkgs;
      };

      programs = {
        home-manager = {
          enable = true;
        };
      };

      targets.genericLinux.enable = true;

      xdg = {
        dataFile.nixpkgs.source = nixpkgs;
        configFile."nix/nix.conf".text = ''
          flake-registry = ${config.xdg.configHome}/nix/registry.json
        '';
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
        };
      }
    );
in
lib.mapAttrs genConfiguration (lib.filterAttrs (_: host: host.type == "home-manager") self.hosts)
