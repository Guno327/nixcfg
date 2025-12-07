{
  description = "sops management shell";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    sops-nix.url = "github:Mic92/sops-nix";
  };

  outputs = { self, nixpkgs, flake-utils, sops-nix }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system}; in
      {
        devShells.default = pkgs.mkShell {
        sopsPGPKeyDirs = [
          "${toString ./.}/keys/hosts"
          "${toString ./.}/keys/users"
        ];
        sopsGPGHome = "${toString ../.}/../gnupg";
        nativeBuildInputs = [
          (pkgs.callPackage sops-nix { }).sops-import-keys-hook
        ];
        };
      });
}
