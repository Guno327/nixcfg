{...}: {
  imports = [
    ./media.nix
    ./cloudflared.nix
    ./adblock.nix
    ./mail.nix
    ./website.nix
    ./playit.nix
    ./satisfactory.nix
    ./nvidia.nix
    ./nextcloud.nix
  ];
}
