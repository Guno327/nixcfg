let
  gunnar-server = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID/Kn8RT4PwTp3fU1nEqrXuRA7DTk6kjrog4EhoXyQxB gunnar@nixos-server";

  server = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAqyehZ93LdlhHh6hEgcLPsQ3zL0Psn7/ASJTPfwsIms root@nixos";
in {
  "secret1.age".publicKeys = [
    gunnar-server
    server
  ];
}
