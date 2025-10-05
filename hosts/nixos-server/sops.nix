{...}: {
  sops.secrets = {
    cloudflare = {};
    dns = {};
    web = {};
    nextcloud = {};

    bazarr = {};
    jellyfin = {};
    jellyseerr = {};
    prowlarr = {};
    radarr = {};
    sonarr = {};

    playit = {
      sopsFile = ../../secrets/playit.toml;
      format = "binary";
      owner = "playit";
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

    tunnel = {
      sopsFile = ../../secrets/tunnel.json;
      format = "json";
      key = "";
    };
  };
}
