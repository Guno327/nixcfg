{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
{
  sops.secrets.temps-endpoint = { };

  environment.systemPackages = with pkgs; [ ipmitool ];
  systemd.services.fancontrol = {
    enable = true;
    description = "Set static fan speed via ipmi";

    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];

    path = with pkgs; [
      ipmitool
      curl
      gawk
    ];

    environment = {
      MANUAL_MODE = "0x30 0x30 0x01 0x00";
      SET_FAN = "0x30 0x30 0x02 0xff";
      SPEED = "0x1E";
    };

    serviceConfig = {
      Type = "simple";
      RemainAfterExit = false;
      User = "root";
      Group = "root";

      ExecStartPre = pkgs.writeShellScript "fancontrol-prestart" ''
        #! /usr/bin/env bash
        echo "Enabling manual mode"
        ipmitool raw $MANUAL_MODE 

        echo "Setting fan speed to $SPEED"
        ipmitool raw $SET_FAN $SPEED
      '';

      ExecStart = pkgs.writeShellScript "fancontrol" ''
        #!/usr/bin/env bash
        set -euo pipefail

        ENDPOINT=$(< ${config.sops.secrets.temps-endpoint.path})
        ENDPOINT="''${ENDPOINT//[$'\t\r\n ']/}"

        count_70=0; count_80=0; count_85=0
        sent_70=0;  sent_80=0;  sent_85=0

        while :; do
          temps=$(ipmitool sensor | awk -F'|' '$1 ~ /^ *Temp *$/ { gsub(/ /,"",$2); print int($2) }')
          { IFS= read -r cpu1; IFS= read -r cpu2; } <<< "$temps"

          if [[ -z "$cpu1" || -z "$cpu2" ]]; then
            echo "WARNING: failed to read temps" >&2
            sleep 60
            continue
          fi

          echo "CPU1=$cpu1, CPU2=$cpu2"

          if (( cpu1 >= 85 || cpu2 >= 85 )); then
            (( ++count_85, ++count_80, ++count_70 ))
          elif (( cpu1 >= 80 || cpu2 >= 80 )); then
            count_85=0; sent_85=0
            (( ++count_80, ++count_70 ))
          elif (( cpu1 >= 70 || cpu2 >= 70 )); then
            count_85=0; sent_85=0
            count_80=0; sent_80=0
            (( ++count_70 ))
          else
            count_85=0; sent_85=0
            count_80=0; sent_80=0
            count_70=0; sent_70=0
          fi

          if (( count_85 > 0 && ! sent_85 )); then
            curl -fsS -H "X-Priority: 5" -d "WARNING: temps over 85C, shutdown likely! ($cpu1, $cpu2)" \
              "https://ntfy.sh/$ENDPOINT" && sent_85=1
          elif (( count_80 > 60 && ! sent_80 )); then
            curl -fsS -H "X-Priority: 4" -d "WARNING: temps over 80C for an hour ($cpu1, $cpu2)" \
              "https://ntfy.sh/$ENDPOINT" && sent_80=1
          elif (( count_70 > 360 && ! sent_70 )); then
            curl -fsS -H "X-Priority: 3" -d "WARNING: temps over 70C for 6 hours ($cpu1, $cpu2)" \
              "https://ntfy.sh/$ENDPOINT" && sent_70=1
          fi

          sleep 60
        done
      '';
    };
  };
}
