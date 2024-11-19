{ withSystem, inputs, ... }:
let
  inherit (inputs)
    self
    nix-darwin
    nixpkgs
    ;
  inherit (nixpkgs) lib;

  genConfiguration =
    hostname:
    { hostPlatform, type, ... }:
    withSystem hostPlatform (
      {
        pkgs,
        system,
        ...
      }:
      nix-darwin.lib.darwinSystem {
        inherit pkgs system;
        modules = [
          (../hosts + "/${hostname}")
          {
            nix = {
              nixPath = [ "nixpkgs=/run/current-system/sw/nixpkgs" ];
              registry = {
                self.flake = self;
                nixpkgs.flake = nixpkgs;
                p.flake = nixpkgs;
              };
            };
          }
          inputs.home-manager.darwinModules.home-manager
          inputs.nix-index-database.darwinModules.nix-index
        ];
        specialArgs = {
          hostType = type;
          inherit (inputs)
            self
            ;
        };
      }
    );
in
lib.mapAttrs genConfiguration (lib.filterAttrs (_: host: host.type == "nix-darwin") self.hosts)
