{ ... }:
{
  sops.secrets = {
    web = { };
    bazarr = { };
    jellyfin = { };
    jellyseerr = { };
    prowlarr = { };
    radarr = { };
    sonarr = { };
    nextcloud = { };
    authentik = { };

    dns-01 = {
      owner = "acme";
      mode = "0600";
    };

    wireguard = {
      sopsFile = ../../secrets/wg0.conf;
      format = "binary";
    };

    transmission = {
      sopsFile = ../../secrets/transmission.json;
      format = "json";
      key = "";
    };
  };
}
