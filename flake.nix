{
  inputs = {
    garnix-lib.url = "github:garnix-io/garnix-lib";
  };

    caelestia-shell = {
      url = "github:caelestia-dots/shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";
    stylix.url = "github:danth/stylix";
    mailserver.url = "gitlab:simple-nixos-mailserver/nixos-mailserver";
    playit-nixos-module.url = "github:pedorich-n/playit-nixos-module";
    nixarr.url = "github:rasmus-kirk/nixarr";
  nixConfig = {
    extra-substituters = [ "https://cache.garnix.io" ];
    extra-trusted-public-keys = [ "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g=" ];
  };

  outputs = inputs: inputs.garnix-lib.lib.mkModules {
    modules = [
    ];

    config = { pkgs, ... }: {

      garnix.deployBranch = "main";
    };
  };
}
