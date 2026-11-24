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
              # NOTE: flake config name, for tooling (e.g. nixd LSP config)
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
              { stylix.enableReleaseChecks = false; }
              # NOTE: common/stylix is imported at system level only, so the
              #   home-manager users get the target policy here.
              ../common/stylix/follow-programs.nix
              inputs.amzn-community.homeModules.default
              inputs.sops-nix.homeManagerModules.sops
            ];
          }
          inputs.home-manager.darwinModules.home-manager
          inputs.mac-app-util.darwinModules.default
          inputs.kanata-darwin.darwinModules.default
          inputs.stylix.darwinModules.stylix
          # NOTE: system-level module for future darwin-scoped secrets (launchd env, etc.)
          inputs.sops-nix.darwinModules.sops
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
