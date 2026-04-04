{ withSystem, inputs, ... }:
let
  inherit (inputs)
    self
    nix-darwin
    nixpkgs
    ;
  inherit (nixpkgs) lib;

  genConfiguration =
    hostName:
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
          (../hosts + "/${hostName}")
          {
            environment.variables = {
              # WARN: Using this in Neovim nix lsp configs, until I can find something smarter
              _NIX_HOSTNAME = hostName;
            };
            nix = {
              nixPath = [ "nixpkgs=/run/current-system/sw/nixpkgs" ];
              registry = {
                self.flake = self;
                nixpkgs.flake = nixpkgs;
                p.flake = nixpkgs;
              };
            };
            home-manager.extraSpecialArgs = {
              inherit hostName inputs;
            };
            home-manager.sharedModules = [
              inputs.mac-app-util.homeManagerModules.default
              inputs.nix-index-database.homeModules.default
              { programs.nix-index-database.comma.enable = true; }
            ];
          }
          inputs.home-manager.darwinModules.home-manager
          inputs.mac-app-util.darwinModules.default
          inputs.stylix.darwinModules.stylix
        ];
        specialArgs = {
          hostType = type;
          inherit (inputs) self;
          inherit inputs;
        };
      }
    );
in
lib.mapAttrs genConfiguration (lib.filterAttrs (_: host: host.type == "nix-darwin") self.hosts)
