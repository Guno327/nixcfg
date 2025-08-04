{
  description = ''
    Flake for Guno327's nix installs
  '';

  inputs = {
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    custom-pkgs = {
      url = "github:guno327/pkgs";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.05";

    nvf = {
      url = "github:notashelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";
    stylix.url = "github:danth/stylix";
    mailserver.url = "gitlab:simple-nixos-mailserver/nixos-mailserver";
    playit-nixos-module.url = "github:pedorich-n/playit-nixos-module";
    nixarr.url = "github:rasmus-kirk/nixarr";

    mineflake.url = "github:guno327/mineflake";
  };

  outputs = {
    self,
    home-manager,
    nixpkgs,
    nixos-hardware,
    nvf,
    nix-flatpak,
    stylix,
    mailserver,
    playit-nixos-module,
    nixarr,
    mineflake,
    ...
  } @ inputs: let
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
    packages = forAllSystems (system: nixpkgs.legacyPackages.${system});
    overlays = import ./overlays {inherit inputs;};
    formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.alejandra;

    nixosConfigurations = {
      nixos-laptop = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs outputs;};
        modules = [
          ./hosts/nixos-laptop

          nixos-hardware.nixosModules.common-cpu-amd
          nixos-hardware.nixosModules.common-gpu-amd
          nixos-hardware.nixosModules.common-pc-laptop

          nvf.nixosModules.default
          stylix.nixosModules.stylix
          nix-flatpak.nixosModules.nix-flatpak
        ];
      };
      nixos-desktop = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs outputs;};
        modules = [
          ./hosts/nixos-desktop

          nixos-hardware.nixosModules.common-cpu-amd
          nixos-hardware.nixosModules.common-gpu-amd
          nixos-hardware.nixosModules.common-pc-ssd

          nvf.nixosModules.default
          stylix.nixosModules.stylix
          nix-flatpak.nixosModules.nix-flatpak
        ];
      };

      nixos-server = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs outputs;};
        modules = [
          ./hosts/nixos-server

          nvf.nixosModules.default
          stylix.nixosModules.stylix
          mailserver.nixosModule
          playit-nixos-module.nixosModules.default
          nixarr.nixosModules.default

          mineflake.nixosModules.vanilla
        ];
      };
    };

    homeConfigurations = {
      "gunnar@nixos-laptop" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages."x86_64-linux";
        extraSpecialArgs = {inherit inputs outputs;};
        modules = [./home/gunnar/nixos-laptop.nix];
      };

      "gunnar@nixos-desktop" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages."x86_64-linux";
        extraSpecialArgs = {inherit inputs outputs;};
        modules = [./home/gunnar/nixos-desktop.nix];
      };

      "gunnar@nixos-server" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages."x86_64-linux";
        extraSpecialArgs = {inherit inputs outputs;};
        modules = [./home/gunnar/nixos-server.nix];
      };
    };
  };
}
