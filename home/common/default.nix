{
  lib,
  pkgs,
  outputs,
  inputs,
  ...
}:
{
  imports = [
    inputs.sops-nix.homeManagerModules.sops
    inputs.caelestia-shell.homeManagerModules.default
    inputs.zen-browser.homeModules.twilight
  ];

  nixpkgs = {
    # configure overlays from flake
    overlays = [
      outputs.overlays.stable-packages
    ];

    # Configure your nixpkgs instance
    config = {
      allowUnfree = true;
      allowUnfreePredicate = _: true;
    };
  };

  nix = {
    package = lib.mkDefault pkgs.nix;
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      warn-dirty = false;
    };
  };
}
