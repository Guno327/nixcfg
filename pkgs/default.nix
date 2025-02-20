{pkgs, ...}: {
  exiled-exchange-2 = pkgs.callPackage ./exiled-exchange-2 {};
  awakened-poe-trade = pkgs.callPackage ./awakened-poe-trade {};
}
