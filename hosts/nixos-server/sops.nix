{...}: {
  sops.secrets = {
    web = {};

    bazarr = {};
    jellyfin = {};
    jellyseerr = {};
    prowlarr = {};
    radarr = {};
    sonarr = {};

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
