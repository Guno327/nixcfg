{ config, ... }: { 
  

  imports = [ 
    ./home.nix
    ./dotfiles
    ../features/cli
    ../features/desktop
    ../common 
  ];

  features = {
    cli = {
      fish.enable = true;
      git.enable = true;
      fzf.enable = true;
      neofetch.enable = true;
    };
    desktop = {
      wayland.enable = true;
      hyprland.enable = true;
      waybar.enable = true;
      fonts.enable = true;
    };
  };

  wayland.windowManager.hyprland = {
    settings = {
      monitor = [
        "eDP-1,1920x1080@240,0x0,1"
	",preferred, auto, 1, mirror, eDP-1"
      ];

      workspace = [
        "1, monitor:eDP-1, default:true"
	"2, monitor:eDP-1"
	"3, monitor:eDP-1"
	"4, monitor:eDP-1"
	"5, monitor:eDP-1"
      ];
    };
  };
}
