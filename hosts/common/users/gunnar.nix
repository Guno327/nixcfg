{
  config,
  pkgs,
  inputs,
  ...
}:
{
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
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDusj2sISBxt6QzjiiYQezn3dECHVMxiwytKQDhsmoO3 gunnar@gunnar-laptop-arch"  
    ];
    packages = [inputs.home-manager.packages.${pkgs.system}.default];
  };
  home-manager.users.gunnar =
    import ../../../home/gunnar/${config.networking.hostName}.nix;
}
