{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.srvs.incus;
in
{
  options.srvs.incus = with lib; {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable incus using pinned 24.11 binaries.";
    };
    webhook = mkOption {
      type = types.submodule {
        options = {
          enable = mkOption {
            type = types.bool;
            default = false;
            description = "Whether to enable the MAAS webhook service.";
          };
        };
      };
      default = { };
      description = "Webhook listener configuration.";
    };
  };

  config = lib.mkIf cfg.enable {
    sops.secrets.incus-redfish = {
      owner = "incus-redfish";
      group = "incus-admin";
      mode = "0660";
    };

    virtualisation.incus = {
      enable = true;
    };

    services.incus-redfish = {
      enable = true;
      host = "192.168.0.1";
      port = 9001;
      environmentFile = config.sops.secrets.incus-redfish.path;
    };
  };
}
