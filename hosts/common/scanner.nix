{ pkgs, ... }:
{
  hardware.sane.enable = true;
  hardware.sane.extraBackends = [
    (pkgs.epkowa.override {
      plugins = { inherit (pkgs.epkowa.plugins) f720; };
    })
  ];
  users.users.gunnar.extraGroups = [
    "scanner"
    "lp"
  ];
}
