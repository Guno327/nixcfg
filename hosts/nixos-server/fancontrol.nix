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
    };

    serviceConfig = {
      Type = "simple";
      RemainAfterExit = false;
      User = "root";
      Group = "root";

      ExecStart = pkgs.writers.writeFish "fancontrol" ''
        set -l INTERVAL 60        # seconds between checks
        set -l WINDOW 3           # rolling-average sample count (3 * 60s = 3 min)
        set -l WARN_TEMP 85       # send warning when avg >= this
        set -l CLEAR_TEMP 80      # clear warning once avg drops below this (hysteresis)

        set -g ENDPOINT (string trim < ${config.sops.secrets.temps-endpoint.path})

        function notify --argument-names prio msg   # reads global ENDPOINT
          curl -fsS -H "X-Priority: $prio" -d "$msg" "https://ntfy.sh/$ENDPOINT"
          or echo "WARNING: ntfy failed" >&2
        end

        function fan_pct --argument-names t          # duty-cycle % per the curve
          if test $t -ge 80
            echo 40
          else if test $t -ge 70
            echo 30
          else if test $t -ge 60
            echo 20
          else if test $t -ge 50
            echo 10
          else
            echo 0
          end
        end

        echo "Enabling manual fan mode"
        ipmitool raw (string split -n ' ' -- $MANUAL_MODE)

        set -l samples
        set -l warned 0
        set -l last_pct -1

        while true
          set -l temps (ipmitool sensor | awk -F'|' '$1 ~ /^ *Temp *$/ { gsub(/[^0-9.]/,"",$2); if ($2 != "") print int($2) }')
          set -l cpu1 $temps[1]
          set -l cpu2 $temps[2]

          if test -z "$cpu1" -o -z "$cpu2"
            echo "WARNING: failed to read temps" >&2
            sleep $INTERVAL
            continue
          end

          # hottest socket drives the fan and the alerting
          set -l temp $cpu1
          test $cpu2 -gt $temp; and set temp $cpu2

          # --- fan curve: instantaneous, only re-issue on change ---
          set -l pct (fan_pct $temp)
          if test $pct -ne $last_pct
            set -l hex (printf '0x%02x' $pct)
            echo "CPU1=$cpu1 CPU2=$cpu2 -> fan $pct%"
            ipmitool raw (string split -n ' ' -- $SET_FAN) $hex
            set last_pct $pct
          else
            echo "CPU1=$cpu1 CPU2=$cpu2 -> fan $pct% (unchanged)"
          end

          # --- rolling average for alerting ---
          set -a samples $temp
          if test (count $samples) -gt $WINDOW
            set samples $samples[2..-1]
          end
          set -l n (count $samples)
          set -l sum 0
          for s in $samples
            set sum (math "$sum + $s")
          end
          set -l avg (math "floor($sum / $n)")

          if test $warned -eq 0 -a $avg -ge $WARN_TEMP
            notify 5 "WARNING: avg temp "$avg"C (CPU1=$cpu1 CPU2=$cpu2), throttle/shutdown likely!"
            set warned 1
          else if test $warned -eq 1 -a $avg -lt $CLEAR_TEMP
            notify 3 "Recovered: avg temp back to "$avg"C (CPU1=$cpu1 CPU2=$cpu2)"
            set warned 0
          end

          sleep $INTERVAL
        end
      '';
    };
  };
}
