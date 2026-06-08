{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.srvs.discmod;
in
{
  options.srvs.discmod = {
    enable = mkEnableOption "Enable discmod service";
  };

  config = mkIf cfg.enable {
    sops.secrets.discmod-env = {
      owner = "discmod";
      group = "discmod";
      mode = "660";
    };

    environment.systemPackages = with pkgs; [ packwiz ];

    services.discmod = {
      enable = true;
      modrinthUserAgent = "guno327/discmod/0.1.0 (discmod@ghov.net)";
      extraPackages = [ pkgs.packwiz ];
      environmentFile = config.sops.secrets.discmod-env.path;
      minApprovals = 0;
      botGitEmail = "discmod@ghov.net";
    };
  };
}
