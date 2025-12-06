{
  config,
  pkgs,
  inputs,
  ...
}: {
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
      "adbusers"
      "tss"
    ];
    packages = [inputs.home-manager.packages.${pkgs.stdenv.hostPlatform.system}.default];
    openssh.authorizedKeys.keys = ["ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCoo8LEabSN+Q/UKxVnJ3tYMWPscS87TTNo5n0WIBhg4/wzywrp7rxUeomOd8zBZ1H/wKPL0F/ks/3WlDUCOJu92AFwIwsbJ5SIeJtJJ1J1UfTiH1pb8eEuXLzPiLGaweOj6W0xrGxsZzDpX+RaashKRhBh84kaDuwzrvErCgaKDv3QjD1tS8LOaF/o/wT9bNizwkkilx6ih3SzRV9l27hrAOxHZnqV+cmXTSiQzIGj5ZoqoRNwgy2aD5r/caCJlrCCgAVb86cyOYAWcLJL/h7kCYxBwT49lISgSZw67B0L60hidBfk0hKYsdWAfh8yXFcFYwNwDVbP71bE351swRfN openpgp:0x7AA5E060"];
  };
  home-manager.users.gunnar = import ../../../home/gunnar/${config.networking.hostName}.nix;
}
