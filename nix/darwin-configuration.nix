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
            nix.registry = {
              p.flake = nixpkgs;
            };
          }
        ];
        specialArgs = {
          hostType = type;
          inherit (inputs)
            home-manager
            nix-index-database
            self
            ;
        };
      }
    );
in
lib.mapAttrs genConfiguration (lib.filterAttrs (_: host: host.type == "nix-darwin") self.hosts)
