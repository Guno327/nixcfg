with import <nixpkgs> { };
let
  sops-nix = builtins.fetchTarball {
    url = "https://github.com/Mic92/sops-nix/archive/master.tar.gz";
  };
in
mkShell {
  sopsPGPKeyDirs = [
    "${toString ./.}/keys/hosts"
    "${toString ./.}/keys/users"
  ];
  sopsGPGHome = "${toString ../.}/../gnupg";
  nativeBuildInputs = [
    (pkgs.callPackage sops-nix { }).sops-import-keys-hook
  ];
}
