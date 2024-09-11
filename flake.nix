{
  description = "My system configuration";

  nixConfig = {
    extra-trusted-substituters = [
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  inputs = {
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      self,
      home-manager,
      nixpkgs,
      nix-darwin,
      ...
    }:
    let
      homeManagerModule = import ./aarch64-darwin/home.nix;
      configuration = import ./aarch64-darwin/configuration.nix {
        inherit pkgs;
        inherit self;
        inherit system;
      };
      hostname = "80a99738471f";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      system = "aarch64-darwin";
    in
    {
      darwinConfigurations.${hostname} = nix-darwin.lib.darwinSystem {
        inherit system;
        modules = [
          configuration
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.angaidan = homeManagerModule;
          }
        ];
      };

      # Expose the package set, including overlays, for convenience.
      darwinPackages = self.darwinConfigurations.${hostname}.pkgs;
    };
}
