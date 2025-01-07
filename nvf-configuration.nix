{ pkgs, lib, ... } : {
  vim.theme = {
    enable = true;
    name = "dracula";
    style = "dark";
  };

  vim.languages.nix.enable = true;
}
