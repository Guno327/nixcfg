{ config, ... }: { 
  

  imports = [ 
    ./home.nix
    ../features/cli
    ../common 
  ];

  features = {
    cli = {
      fish.enable = true;
    };
  };
}
