{...}: {
  imports = [
    ./media.nix
    ./cloudflared.nix
    ./pihole.nix
    ./mail.nix
    ./website.nix
    ./playit.nix
    ./satisfactory.nix
    ./github-runner.nix
    ./nvidia.nix
    ./nextcloud.nix
    ./homepage.nix
  ];
}
