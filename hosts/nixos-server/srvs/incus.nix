{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.srvs.incus;

  incus-webhook =
    pkgs.writers.writePython3 "incus_webhook.py"
      {
        libraries = with pkgs.python3Packages; [ flask ];
        flakeIgnore = [
          "E501"
          "E302"
          "W391"
        ];
      }
      ''
        from flask import Flask, jsonify
        import subprocess

        app = Flask(__name__)

        def run_incus_command(command):
            """Executes an incus CLI command and returns the output."""
            try:
                result = subprocess.run(command, capture_output=True, text=True, check=True)
                return True, result.stdout.strip()
            except subprocess.CalledProcessError as e:
                return False, e.stderr.strip()

        @app.route('/powerstatus/<project>/<vm_name>', methods=['GET'])
        def power_status(project, vm_name):
            """Queries the current power status of the Incus VM."""
            success, output = run_incus_command(['incus', 'info', vm_name, '--project', project])
            if not success:
                return jsonify({"status": "unknown", "error": output}), 400

            if "Status: RUNNING" in output:
                return jsonify({"status": "running"}), 200
            elif "Status: STOPPED" in output:
                return jsonify({"status": "stopped"}), 200
            else:
                return jsonify({"status": "unknown", "raw_output": output}), 200

        @app.route('/poweron/<project>/<vm_name>', methods=['POST', 'PUT'])
        def power_on(project, vm_name):
            """Starts the Incus VM."""
            success, output = run_incus_command(['incus', 'start', vm_name, '--project', project])
            if success or "The instance is already running" in output:
                return jsonify({"status": "on"}), 200
            else:
                return jsonify({"status": "error", "error": output}), 500

        @app.route('/poweroff/<project>/<vm_name>', methods=['POST', 'PUT'])
        def power_off(project, vm_name):
            """Force stops the Incus VM."""
            success, output = run_incus_command(['incus', 'stop', '-f', vm_name, '--project', project])
            if success or "The instance is already stopped" in output:
                return jsonify({"status": "off"}), 200
            else:
                return jsonify({"status": "error", "error": output}), 500
      '';

  pythonEnv = pkgs.python3.withPackages (
    ps: with ps; [
      flask
      gunicorn
    ]
  );

  webhookDir = pkgs.runCommand "incus-webhook-dir" { } ''
    mkdir -p $out
    cp ${incus-webhook} $out/incus_webhook.py
  '';
in
{
  options.srvs.incus = with lib; {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable incus using pinned 24.11 binaries.";
    };
    user = mkOption {
      type = types.str;
      default = "root";
      description = "User to allow access to incus cli";
    };
    webhook = mkOption {
      type = types.submodule {
        options = {
          enable = mkOption {
            type = types.bool;
            default = false;
            description = "Whether to enable the MAAS webhook service.";
          };
          bind = mkOption {
            type = types.str;
            default = "0.0.0.0:5000";
            description = "The address the webhook listener binds to.";
          };
        };
      };
      default = { };
      description = "Webhook listener configuration.";
    };
  };

  config = lib.mkIf cfg.enable {
    virtualisation.incus = {
      enable = true;
    };
    users.users."${cfg.user}".extraGroups = [ "incus-admin" ];

    systemd.services.incus-webhook = lib.mkIf cfg.webhook.enable {
      description = "MAAS webhook to allow interaction with incus";
      wantedBy = [ "multi-user.target" ];
      after = [
        "network.target"
        "incus.service"
      ];
      path = [ pkgs.incus ];
      serviceConfig = {
        Type = "simple";
        User = "root";
        WorkingDirectory = webhookDir;
        ExecStart = "${pythonEnv}/bin/gunicorn --workers 4 --bind ${cfg.webhook.bind} incus_webhook:app";
        Restart = "on-failure";
        RestartSec = "5s";
      };
    };
  };
}
