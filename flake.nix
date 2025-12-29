{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable/";
    
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
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, nix-darwin, mac-app-util, haruka-nur, ... }@inputs:
    let
      username = "haruka";
      darwin-workstation = "apple-seeds";
      darwinSystem = "aarch64-darwin";
      amd64 = nixpkgs.legacyPackages.x86_64-linux;
    in 
    {
      darwinConfigurations.${darwin-workstation} = nix-darwin.lib.darwinSystem {
        system = darwinSystem;
        specialArgs = { inherit inputs username darwin-workstation; };
        modules = [
          mac-app-util.darwinModules.default
          home-manager.darwinModules.home-manager
          ./configs/darwin.nix
          {
            nixpkgs.overlays = [ haruka-nur.overlays.mac-apps ];
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { inherit username; };
            home-manager.sharedModules = [ mac-app-util.homeManagerModules.default ];
            home-manager.users.${username} = import ./configs/home.nix;
          }
        ];
      };

      homeConfigurations.${username} = home-manager.lib.homeManagerConfiguration {
        pkgs = amd64;
        extraSpecialArgs = { inherit username; };
        modules = [ ./configs/home.nix ];
      };
    };
}
