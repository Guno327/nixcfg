{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.features.cli.ai;
  api-key = builtins.replaceStrings ["\n"] [""] (builtins.readFile ../../../secrets/gemini-api.key);
in {
  options.features.cli.ai.enable = mkEnableOption "enable gemini ai for fish";
  config = mkIf cfg.enable {
    home.packages = with pkgs; [glow jq];
    programs.fish = {
      functions = {
        ai = ''
          set content (string join ' ' $argv)
          echo -n '{ "contents": [ { "parts": [ { "text": "'$content'" } ] } ] }' | \
          curl --silent \
              --header 'Content-Type: application/json' \
              --data @- \
              --request POST \
              "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=${api-key}" | \
          jq -r '.candidates[].content.parts[].text' | glow
        '';
      };
    };
  };
}
