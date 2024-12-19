# A staring point is the basic NIXOS configuration generated by the ISO installer.
# On an existing NIXOS install you can use the following command in your flakes basedir:
# sudo nixos-generate-config --dir ./hosts/nixos-vm
# 
# Please make sure to change the first couple of lines in your configuration.nix:

# { config, inputs, ouputs, lib, pkgs, ... }:
#
# {
#   imports = [ # Include the results of the hardware scan.
#     ./hardware-configuration.nix
#     inputs.home-manager.nixosModules.home-manager
#   ];
#   ...
#
# Moreover please update the packages option in your user configuration and add the home-manager options:

# users.users = {
#   gunnar = {
#     isNormalUser = true;
#     initialPassword = "12345";
#     extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
#     packages = [ inputs.home-manager.packages.${pkgs.system}.default ];
#   };
# };
#
# home-manager = {
#   useUserPackages = true;
#   extraSpecialArgs = { inherit inputs outputs; };
#   users.gunnar =
#     import ../../home/gunnar/${config.networking.hostName}.nix;
# };
#
# Please also change your hostname accordingly:
#:w

# networking.hostName = "nixos"; # Define your hostname.

{
  imports = [ ../common ./configuration.nix ];
}
