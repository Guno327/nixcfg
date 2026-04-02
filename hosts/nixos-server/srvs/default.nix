{ ... }:
{
  imports = [
    ./traefik.nix
    ./media.nix
    ./adblock.nix
    ./satisfactory.nix
    ./nvidia.nix
    ./minecraft.nix
    ./about.nix
    ./nextcloud.nix
    ./lxd.nix
    ./authentik.nix
    ./opencloud.nix
  ];
}
