{config, ...}: {
  sops.secrets."obadmin-id_rsa" = {
    sopsFile = ../../secrets/canonical.yaml;
  };

  programs.ssh.extraConfig = ''
    # Orangebox Wireguard GW (Public IPs - Location AWS US-West1)
    Host ob-vpn.orangebox.me ob-vpn
      PreferredAuthentications publickey
      PubkeyAuthentication yes
      PasswordAuthentication no
      User ubuntu
      IdentityFile /flake/hosts/common/users/gpg.pub
      AddKeysToAgent yes
      AddressFamily inet
      CheckHostIP no
      ForwardAgent yes
      ForwardX11 yes
      ForwardX11Trusted yes
      LogLevel FATAL
      SendEnv LANG LC_*
      StrictHostKeyChecking no
      UserKnownHostsFile /dev/null
      XAuthLocation /usr/bin/xauth
      ServerAliveInterval 6
      ServerAliveCountMax 9
      RequestTTY yes

    # OrangeBox Jumphosts (Wireguard IPs for Node00: wg0)
    Host orangebox?? orangebox??? ob?? ob???
      PreferredAuthentications publickey
      PubkeyAuthentication yes
      PasswordAuthentication no
      User ubuntu
      IdentityFile /flake/hosts/common/users/gpg.pub
      AddKeysToAgent yes
      AddressFamily inet
      CheckHostIP no
      ForwardAgent yes
      ForwardX11 yes
      ForwardX11Trusted yes
      LogLevel FATAL
      SendEnv LANG LC_*
      StrictHostKeyChecking no
      UserKnownHostsFile /dev/null
      XAuthLocation /usr/bin/xauth
      ServerAliveInterval 6
      ServerAliveCountMax 9
      RequestTTY yes
      ProxyJump ob-vpn.orangebox.me

    # OrangeBox Routers (Wireguard IPs for each OB's Mikrotik Router Iface: wg0)
    Host ob??-rtr ob???-rtr ob??-rtr.* ob???-rtr.*
      PreferredAuthentications publickey
      PubkeyAcceptedKeyTypes +ssh-rsa
      PubkeyAuthentication yes
      PasswordAuthentication no
      User obadmin
      IdentityFile ${config.sops.secrets."obadmin-id_rsa".path}
      AddKeysToAgent yes
      AddressFamily inet
      CheckHostIP no
      ForwardX11 no
      ForwardX11Trusted no
      LogLevel FATAL
      StrictHostKeyChecking no
      UserKnownHostsFile /dev/null
      ServerAliveInterval 6
      ServerAliveCountMax 9
      ProxyJump ob-vpn.orangebox.me
  '';

  networking = {
    extraHosts = ''
      ###########################
      # Orangebox Remote Access #
      ###########################

      ## WG Gateways (Public IPs-Location: AWS)

      #### AMER - US-West-1
      3.101.20.212		ob-vpn.orangebox.me ob-vpn

      ## Orangebox Jumphosts (Wireguard IPs for Node00 Iface: wg0)
      192.168.250.8	orangebox08.orangebox.me orangebox08 ob08
      192.168.250.12	orangebox12.orangebox.me orangebox12 ob12
      192.168.250.16	orangebox16.orangebox.me orangebox16 ob16
      192.168.250.20	orangebox20.orangebox.me orangebox20 ob20
      192.168.250.24	orangebox24.orangebox.me orangebox24 ob24
      192.168.250.28	orangebox28.orangebox.me orangebox28 ob28
      192.168.250.32	orangebox32.orangebox.me orangebox32 ob32
      192.168.250.36	orangebox36.orangebox.me orangebox36 ob36
      192.168.250.40	orangebox40.orangebox.me orangebox40 ob40
      192.168.250.44	orangebox44.orangebox.me orangebox44 ob44
      192.168.250.48	orangebox48.orangebox.me orangebox48 ob48
      192.168.250.52	orangebox52.orangebox.me orangebox52 ob52
      192.168.250.56	orangebox56.orangebox.me orangebox56 ob56
      192.168.250.60	orangebox60.orangebox.me orangebox60 ob60
      192.168.250.64	orangebox64.orangebox.me orangebox64 ob64
      192.168.250.68	orangebox68.orangebox.me orangebox68 ob68
      192.168.250.72	orangebox72.orangebox.me orangebox72 ob72
      192.168.250.76	orangebox76.orangebox.me orangebox76 ob76
      192.168.250.80	orangebox80.orangebox.me orangebox80 ob80
      192.168.250.84	orangebox84.orangebox.me orangebox84 ob84
      192.168.250.88	orangebox88.orangebox.me orangebox88 ob88
      192.168.250.92	orangebox92.orangebox.me orangebox92 ob92
      192.168.250.96	orangebox96.orangebox.me orangebox96 ob96
      192.168.250.100	orangebox100.orangebox.me orangebox100 ob100
      192.168.250.104	orangebox104.orangebox.me orangebox104 ob104
      192.168.250.240	orangebox240.orangebox.me orangebox240 ob240
      192.168.250.248	orangebox88.orangebox.me orangebox248 ob248

      ## OrangeBox Routers (Wireguard IPs for each OB's Mikrotik Router Iface: wg0)
      192.168.250.9	ob08-rtr.orangebox.me ob08-rtr
      192.168.250.13	ob12-rtr.orangebox.me ob12-rtr
      192.168.250.17	ob16-rtr.orangebox.me ob16-rtr
      192.168.250.21	ob20-rtr.orangebox.me ob20-rtr
      192.168.250.25	ob24-rtr.orangebox.me ob24-rtr
      192.168.250.29	ob28-rtr.orangebox.me ob28-rtr
      192.168.250.33	ob32-rtr.orangebox.me ob32-rtr
      192.168.250.37	ob36-rtr.orangebox.me ob36-rtr
      192.168.250.41	ob40-rtr.orangebox.me ob40-rtr
      192.168.250.45	ob44-rtr.orangebox.me ob44-rtr
      192.168.250.49	ob48-rtr.orangebox.me ob48-rtr
      192.168.250.53	ob52-rtr.orangebox.me ob52-rtr
      192.168.250.57	ob56-rtr.orangebox.me ob56-rtr
      192.168.250.61	ob60-rtr.orangebox.me ob60-rtr
      192.168.250.65	ob64-rtr.orangebox.me ob64-rtr
      192.168.250.69	ob68-rtr.orangebox.me ob68-rtr
      192.168.250.73	ob72-rtr.orangebox.me ob72-rtr
      192.168.250.77	ob76-rtr.orangebox.me ob76-rtr
      192.168.250.81	ob80-rtr.orangebox.me ob80-rtr
      192.168.250.85	ob84-rtr.orangebox.me ob84-rtr
      192.168.250.89	ob88-rtr.orangebox.me ob88-rtr
      192.168.250.93	ob92-rtr.orangebox.me ob92-rtr
      192.168.250.97	ob96-rtr.orangebox.me ob96-rtr
      192.168.250.101	ob100-rtr.orangebox.me ob100-rtr
      192.168.250.105	ob104-rtr.orangebox.me ob104-rtr
      192.168.250.241	ob240-rtr.orangebox.me ob240-rtr
      192.168.250.249	ob248-rtr.orangebox.me ob248-rtr
    '';
  };
}
