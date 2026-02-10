{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.srvs.virtualisation.lxd;

  # Hardcode the specific Nixpkgs 24.11 release
  lxdPkgs =
    import (builtins.fetchTarball {
      url = "https://github.com/NixOS/nixpkgs/archive/refs/tags/24.11.tar.gz";
      sha256 = "sha256:1gx0hihb7kcddv5h0k7dysp2xhf1ny0aalxhjbpj2lmvj7h9g80a";
    }) {
      system = pkgs.stdenv.hostPlatform.system;
      config.allowUnfree = true;
    };

  preseedFormat = pkgs.formats.yaml {};
in {
  options.srvs.virtualisation.lxd = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable LXD using pinned 24.11 binaries.";
    };

    # Hardcoded to the pinned 24.11 package by default
    package = lib.mkOption {
      type = lib.types.package;
      default = lxdPkgs.lxd-lts;
      description = "The LXD package (pinned to 24.11).";
    };

    lxcPackage = lib.mkOption {
      type = lib.types.package;
      default = lxdPkgs.lxc;
      description = "The lxc package (pinned to 24.11).";
    };

    zfsSupport = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };

    recommendedSysctlSettings = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };

    preseed = lib.mkOption {
      type = lib.types.nullOr (lib.types.submodule {freeformType = preseedFormat.type;});
      default = null;
    };

    startTimeout = lib.mkOption {
      type = lib.types.int;
      default = 600;
      apply = toString;
    };

    ui = {
      enable = lib.mkEnableOption "LXD UI";
      package = lib.mkOption {
        type = lib.types.package;
        default = lxdPkgs.lxd-ui;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    # We use the pinned packages for everything
    environment.systemPackages = [cfg.package];

    systemd.tmpfiles.rules = ["d /var/lib/lxc/rootfs 0755 root root -"];

    security.apparmor = {
      enable = true;
      packages = [cfg.lxcPackage];
      policies = {
        "bin.lxc-start".profile = "include ${cfg.lxcPackage}/etc/apparmor.d/usr.bin.lxc-start";
        "lxc-containers".profile = "include ${cfg.lxcPackage}/etc/apparmor.d/lxc-containers";
      };
    };

    systemd.sockets.lxd = {
      description = "LXD UNIX socket";
      wantedBy = ["sockets.target"];
      socketConfig = {
        ListenStream = "/var/lib/lxd/unix.socket";
        SocketMode = "0660";
        SocketGroup = "lxd";
        Service = "lxd.service";
      };
    };

    systemd.services.lxd = {
      description = "LXD Container Management Daemon";
      wantedBy = ["multi-user.target"];
      after = ["network-online.target"];
      requires = ["network-online.target" "lxd.socket"];
      path = [pkgs.util-linux] ++ lib.optional cfg.zfsSupport lxdPkgs.zfs; # Pin ZFS too

      serviceConfig = {
        ExecStart = "@${cfg.package}/bin/lxd lxd --group lxd";
        ExecStartPost = "${cfg.package}/bin/lxd waitready --timeout=${cfg.startTimeout}";
        ExecStop = "${cfg.package}/bin/lxd shutdown";
        KillMode = "process";
        Delegate = true;
      };
    };

    users.groups.lxd = {};
    users.users.root = {
      subUidRanges = [
        {
          startUid = 1000000;
          count = 65536;
        }
      ];
      subGidRanges = [
        {
          startGid = 1000000;
          count = 65536;
        }
      ];
    };

    # Sysctl and Kernel Modules remain the same...
    boot.kernel.sysctl = lib.mkIf cfg.recommendedSysctlSettings {
      "fs.inotify.max_queued_events" = 1048576;
      "fs.inotify.max_user_instances" = 1048576;
      "fs.inotify.max_user_watches" = 1048576;
    };
    boot.kernelModules = ["veth" "xt_comment" "xt_CHECKSUM" "xt_MASQUERADE"];
  };
}
