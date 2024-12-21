{
  inputs,
  ...
} :
{
  home.file.".scripts" = {
    source = "${inputs.scripts}";
    recursive = true;
   };
}
