{ config, pkgs, inputs, ... }: {
  users.users.gunnar = {
    initialHashedPassword = "$y$j9T$f.RJFc9KNUp2D/m7akp1Q1$Bq95yANVIS.IDTpKN54HnA8fFKa1fsc9odiY.TbvlmD";
    isNormalUser = true;
    description = "gunnar";
    extraGroups = [
      "wheel"
      "networkmanager"
      "libvirtd"
      "flatpak"
      "audio"
      "video"
      "plugdev"
      "input"
      "kvm"
      "qemu-libvirtd"
    ];
    packages = [inputs.home-manager.packages.${pkgs.system}.default];

    openssh.authorizedKeys.keys = [
      "sh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBoQThHfSYuA3wptFtXX5tHs1riSdylil3fL+GU/vTkK gunnar@nixos-desktop"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAj+hihJZbsFkQQdZE+WYYx5hgwZWT5im1s4dwWU3x7p root@nixos-server"
    ];
  };
  home-manager.users.gunnar =
    import ../../../home/gunnar/${config.networking.hostName}.nix;
}
