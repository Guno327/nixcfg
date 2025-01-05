let
  gunnar-server = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPCvfUlvqM845QUvpsRWCtP6INZpN3hZl/PEsvix0Vt5 gunnar@nixos-server";

  server = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOfhAzL3kEqQQ4+Ikr1k/XBAIOOm1Onl6FxwcTKjucXF root@nixos";
in {
  "secret1.age".publicKeys = [ gunnar-server server ];
}
