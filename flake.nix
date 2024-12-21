{
  description = ''
    Flake for Guno327's nix installs
  '';

  inputs = {
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    
    dotfiles = {
      url = "github:Guno327/dotfiles";
      flake = false;
    };

    obsidian-vault = {
      url = "github:Guno327/Obsidian-Vault";
      flake = false;
    };

    scripts = {
      url = "github:Guno327/scripts";
      flake = false;
    };
  };

  outputs = { 
    self,
    dotfiles,
    obsidian-vault,
    scripts,
    home-manager,
    nixpkgs, 
    ... 
    }@inputs: let
      inherit (self) outputs;
      systems = [
        "aarch64-linux"
        "i686-linux"
        "x86_64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in {
      packages =
        forAllSystems (system: import ./pkgs nixpkgs.legacyPackages.${system});
      overlays = import ./overlays { inherit inputs; };
      nixosConfigurations = {
        nixos-vm = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs outputs; };
          modules = [ 
            ./hosts/nixos-vm
          ];
        };
        nixos-laptop = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs outputs; };
          modules = [ 
            ./hosts/nixos-laptop
          ];
        };
      };
      homeConfigurations = {
        "gunnar@nixos-vm" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages."x86_64-linux";
          extraSpecialArgs = { inherit inputs outputs; };
          modules = [ 
            ./home/gunnar/nixos-vm.nix
          ];
        };
        "gunnar@nixos-laptop" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages."x86_64-linux";
          extraSpecialArgs = { inherit inputs outputs; };
          modules = [ 
            ./home/gunnar/nixos-laptop.nix
          ];
        };
      };
    };
}
