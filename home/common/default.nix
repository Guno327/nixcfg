{
  lib,
  inputs,
  pkgs,
  ...
}: {
  nixpkgs = {
    overlays = [inputs.nur.overlays.default];
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
