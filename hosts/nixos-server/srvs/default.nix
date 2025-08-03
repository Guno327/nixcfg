{...}: {
  imports = [
    ./media.nix
    ./cloudflared.nix
    ./minecraft.nix
    ./pihole.nix
    ./mail.nix
    ./website.nix
    ./playit.nix
    ./satisfactory.nix
    ./github-runner.nix
  ];
}
