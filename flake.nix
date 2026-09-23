{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable/";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/release-26.05";
    nixpkgs-stable-darwin.url = "github:NixOS/nixpkgs/nixpkgs-26.05-darwin";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    haruka-nur = {
      url = "github:fractuscontext/nix-nur";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    mac-app-util = {
      url = "github:hraban/mac-app-util";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-stable,
      nixpkgs-stable-darwin,
      home-manager,
      nix-darwin,
      mac-app-util,
      haruka-nur,
      ...
    }@inputs:
    let
      # Host Mac Configuration
      username = "tsubasa";
      hostname = "CONSUMERISM";
      darwinArch = "aarch64-darwin";
      linuxArch = "x86_64-linux";

      pkgs-stable-overlay-darwin = import nixpkgs-stable-darwin {
        system = darwinArch;
        config.allowUnfree = true;
        overlays = [ haruka-nur.overlays.mac-apps ];
      };
    in
    {
      darwinConfigurations.${hostname} = nix-darwin.lib.darwinSystem {
        system = darwinArch;
        specialArgs = { inherit inputs username hostname; };
        modules = [
          mac-app-util.darwinModules.default
          home-manager.darwinModules.home-manager
          ./configs/nix-darwin.nix
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = {
                inherit username pkgs-stable-overlay-darwin;
                pkgs-stable = pkgs-stable-overlay-darwin;
              };
              sharedModules = [ mac-app-util.homeManagerModules.default ];
              users.${username} = import ./configs/home.nix;
            };
          }
        ];
      };

      homeConfigurations.${username} = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${linuxArch};
        extraSpecialArgs = {
          inherit username;
          pkgs-stable = nixpkgs-stable.legacyPackages.${linuxArch};
        };
        modules = [ ./configs/home.nix ];
      };
    };
}
