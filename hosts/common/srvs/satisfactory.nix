{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.srvs.satisfactory;
  appId = "1690800"; # Satisfactory Dedicated Server
  stateDir = "/var/lib/satisfactory";
  installDir = "${stateDir}/gamefiles";
  ficsit = lib.getExe pkgs.ficsit-cli;

  updateScript = pkgs.writeShellScript "satisfactory-update" ''
    set -euo pipefail
    ${pkgs.steamcmd}/bin/steamcmd \
      +force_install_dir ${installDir} \
      +login anonymous \
      +app_update ${appId} validate \
      +quit
  '';

  # Declarative mods: rebuild the profile from scratch each start so removals
  # in cfg.modded.mods actually take effect, then apply to the install dir.
  # ficsit-cli has no non-interactive "add mod to profile" command, so the
  # mods are written into its profiles.json with jq after `profile new`
  # creates the (empty) profile. SML is pulled in automatically as a
  # dependency of any mod.
  modsJson = builtins.toJSON (
    lib.genAttrs cfg.modded.mods (_: {
      version = ">=0.0.0";
      enabled = true;
    })
  );

  modScript = pkgs.writeShellScript "satisfactory-mods" ''
    set -euo pipefail
    profiles="$HOME/.local/share/ficsit/profiles.json"

    ${ficsit} installation add ${installDir} || true
    ${ficsit} profile delete nix || true
    ${ficsit} profile new nix

    tmp=$(mktemp)
    ${lib.getExe pkgs.jq} --argjson mods ${lib.escapeShellArg modsJson} \
      '.profiles.nix.mods = $mods' "$profiles" > "$tmp"
    mv "$tmp" "$profiles"

    ${ficsit} installation set-profile ${installDir} nix
    ${ficsit} apply
  '';
in
{
  options.srvs.satisfactory = {
    enable = lib.mkEnableOption "Satisfactory dedicated server";

    port = lib.mkOption {
      type = lib.types.port;
      default = 7777;
      description = "Game port (TCP + UDP). Passed as -Port= and opened in the firewall.";
    };

    extraArgs = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [
        "-multihome=10.0.0.5"
        "-DisablePacketRouting"
      ];
      description = "Extra arguments appended to FactoryServer.sh.";
    };

    environment = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
      description = "Extra environment variables for the server process.";
    };

    saveDir = lib.mkOption {
      type = lib.types.path;
      default = "${stateDir}/saves";
      description = ''
        Directory holding SaveGames (session saves, blueprints). Symlinked into
        the location the server expects under $HOME.
      '';
    };

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Open cfg.port (TCP + UDP) in the firewall.";
    };

    modded = {
      enable = lib.mkEnableOption "mod support via ficsit-cli";

      mods = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        example = [
          "RefinedPower"
          "DaisyChainAnything"
        ];
        description = ''
          Mod references from ficsit.app (the reference string, not the display
          name). Only dedicated-server-compatible mods will work. Applied on
          every service start; removing a mod here removes it from the server.
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable {
    users.users.satisfactory = {
      isSystemUser = true;
      group = "satisfactory";
      home = stateDir;
    };
    users.groups.satisfactory = { };

    systemd.tmpfiles.rules = [
      "d ${cfg.saveDir} 0750 satisfactory satisfactory -"
      "d ${stateDir}/.config/Epic/FactoryGame/Saved 0750 satisfactory satisfactory -"
      "L+ ${stateDir}/.config/Epic/FactoryGame/Saved/SaveGames - - - - ${cfg.saveDir}"
    ];

    systemd.services.satisfactory = {
      description = "Satisfactory dedicated server";
      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];

      environment = {
        HOME = stateDir;
      }
      // cfg.environment;

      serviceConfig = {
        User = "satisfactory";
        Group = "satisfactory";
        StateDirectory = "satisfactory";
        WorkingDirectory = stateDir;
        Restart = "always";
        RestartSec = 10;
        # First steamcmd run downloads ~10 GB
        TimeoutStartSec = "30min";
        ExecStartPre = [ "${updateScript}" ] ++ lib.optional cfg.modded.enable "${modScript}";
        ExecStart = lib.concatStringsSep " " (
          [
            "${pkgs.steam-run}/bin/steam-run"
            "${installDir}/FactoryServer.sh"
            "-Port=${toString cfg.port}"
          ]
          ++ map lib.escapeShellArg cfg.extraArgs
        );
      };
    };

    networking.firewall = lib.mkIf cfg.openFirewall {
      allowedTCPPorts = [ cfg.port ];
      allowedUDPPorts = [ cfg.port ];
    };
  };
}
