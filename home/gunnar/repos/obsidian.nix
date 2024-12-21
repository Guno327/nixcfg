{
  inputs,
  ...
} :
{
   home.file."Obsidian-Vault" = {
    source = "${inputs.obsidian-vault}";
    recursive = true;
   };
}
