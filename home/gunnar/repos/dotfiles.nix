{
  inputs,
  ...
} :
{
  imports = [
    ./bat.nix
  ];

  # home.file.".config/lvim" = {
  #  source = "${inputs.dotfiles}/lvim";
  #  recursive = true;
  # };
}
