{...}: {
  sops = {
    defaultSopsFile = ../../secrets/sops.yaml;

    age = {
      sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
      generateKey = true;
    };

    secrets = {
      github = {};
      cf = {};

      "nebula/laptop.key" = {owner = "nebula-mesh";};
      "nebula/laptop.crt" = {owner = "nebula-mesh";};
      "nebula/server.key" = {owner = "nebula-mesh";};
      "nebula/server.crt" = {owner = "nebula-mesh";};
      "nebula/desktop.key" = {owner = "nebula-mesh";};
      "nebula/desktop.crt" = {owner = "nebula-mesh";};
      "nebula/ca.crt" = {owner = "nebula-mesh";};

      gemini = {
        owner = "gunnar";
        path = "/home/gunnar/.gemini/api.key";
        mode = "0600";
      };

      sshcontrol = {
        sopsFile = ../../secrets/sshcontrol;
        format = "binary";
        owner = "gunnar";
        path = "/home/gunnar/.gnupg/sshcontrol";
        mode = "0600";
      };

      # Canonical VPN
      "canonical-guno327.crt" = {
        sopsFile = ../../secrets/canonical-vpn.yaml;
      };
      "canonical-guno327.key" = {
        sopsFile = ../../secrets/canonical-vpn.yaml;
      };
      "canonical_ca.crt" = {
        sopsFile = ../../secrets/canonical-vpn.yaml;
      };
      "canonical_ta.key" = {
        sopsFile = ../../secrets/canonical-vpn.yaml;
      };
    };
  };
}
