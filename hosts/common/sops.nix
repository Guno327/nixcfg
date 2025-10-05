{...}: {
  sops = {
    defaultSopsFile = ../../secrets/sops.yaml;

    age = {
      sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
      generateKey = true;
    };

    secrets = {
      cloudflare = {};
      dns = {};
      gemini = {};
      github = {};
      tailscale = {};
      web = {};
      nextcloud = {};

      bazarr = {};
      jellyfin = {};
      jellyseerr = {};
      prowlarr = {};
      radarr = {};
      sonarr = {};

      sshcontrol = {
        sopsFile = ../../secrets/sshcontrol;
        format = "binary";
        owner = "gunnar";
        path = "/home/gunnar/.gnupg/sshcontrol";
        mode = "0600";
      };

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
  };
}
