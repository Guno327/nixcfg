{ ... }:
{
  imports = [
    ./traefik.nix
    ./media.nix
    ./dns.nix
    ./satisfactory.nix
    ./nvidia.nix
    ./about.nix
    ./lxd.nix
    ./authentik.nix
    ./opencloud.nix
    ./valheim.nix
    ./finance.nix
    ./windrose.nix
    ./incus.nix
    ./discmod.nix
  ];
}
