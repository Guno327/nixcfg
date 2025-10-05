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
      tailscale = {};
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
