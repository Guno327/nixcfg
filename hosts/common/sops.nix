{...}: {
  sops = {
    defaultSopsFile = ../../secrets/sops.yaml;

    age = {
      sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
      generateKey = true;
    };

    secrets = {
      gemini = {};
      github = {};
      cf = {};

      "nebula/laptop.key" = {owner = "nebula-mesh";};
      "nebula/laptop.crt" = {owner = "nebula-mesh";};
      "nebula/server.key" = {owner = "nebula-mesh";};
      "nebula/server.crt" = {owner = "nebula-mesh";};
      "nebula/desktop.key" = {owner = "nebula-mesh";};
      "nebula/desktop.crt" = {owner = "nebula-mesh";};
      "nebula/ca.crt" = {owner = "nebula-mesh";};

      sshcontrol = {
        sopsFile = ../../secrets/sshcontrol;
        format = "binary";
        owner = "gunnar";
        path = "/home/gunnar/.gnupg/sshcontrol";
        mode = "0600";
      };
    };
  };
}
