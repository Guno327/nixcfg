{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.srvs.libvirt;
in {
  options.srvs.libvirt.enable = mkEnableOption "Enable and configure virtualisation";
  config = mkIf cfg.enable {
    programs.dconf.enable = true;
    users.users.gunnar.extraGroups = ["libvirtd"];

    environment.systemPackages = with pkgs; [
      virt-manager
      spice
      spice-gtk
      spice-protocol
    ];

    virtualisation = {
      libvirtd = {
        enable = true;
        qemu = {
          swtpm.enable = true;
        };
      };
      spiceUSBRedirection.enable = true;
    };
    services.spice-vdagentd.enable = true;
  };
}
