{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  # Use the packaged app from your project input
  viturePkg = inputs.viture.packages.${pkgs.system}.default;

  viturectl = pkgs.writeShellScriptBin "viturectl" ''
    #!/usr/bin/env bash
    set -euo pipefail

    if [[ $# -lt 1 ]]; then
      echo "usage: viturectl <align|push|pop|zoom-in|zoom-out|shift-left|shift-right|toggle-center-dot>" >&2
      exit 1
    fi

    # Prefer XDG_RUNTIME_DIR; fall back to /run/user/$(id -u)
    RUNDIR="''${XDG_RUNTIME_DIR:-/run/user/$(${pkgs.coreutils}/bin/id -u)}"
    SOCK="''${RUNDIR}/viture.sock"

    if [[ ! -S "''${SOCK}" ]]; then
      echo "viturectl: socket not found: ''${SOCK}" >&2
      exit 2
    fi

    # socat needs numeric type: SOCK_SEQPACKET == 5
    exec ${pkgs.socat}/bin/socat - "UNIX-CONNECT:''${SOCK},type=5" <<<"$1"
  '';
in {
  options.programs.viture = {
    enable = lib.mkEnableOption "Viture XR socket+service";
    serviceEnv = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = {};
      description = "Extra env for the viture user service.";
    };
  };

  config = lib.mkIf config.programs.viture.enable {
    # Only the runtime bits you might want in your user profile
    home.packages = [viturePkg viturectl pkgs.socat];

    # Socket activation in the user session
    systemd.user.sockets.viture = {
      Unit.Description = "Viture command socket";
      Socket = {
        ListenSequentialPacket = "%t/viture.sock";
        SocketMode = "0600";
      };
      Install.WantedBy = ["sockets.target"];
    };

    # Service: starts on first viturectl, or manually
    systemd.user.services.viture = {
      Unit = {
        Description = "Viture XR service";
        After = ["viture.socket"];
        # Requiring can activate the service unexpectedly, and we don't want that
        # Requires = [ "viture.socket" ];
      };
      Service = {
        Type = "simple";
        ExecStart = "${viturePkg}/bin/viture_ar_desktop_wayland_dmabuf";
        ExecStop = "${pkgs.coreutils}/bin/kill -s INT $MAINPID";
        TimeoutStopSec = 1;
        KillMode = "control-group";
        SendSIGKILL = true;
        Restart = "on-failure";
        RestartSec = 1;
        Environment = lib.concatStringsSep " " ([
            "XDG_RUNTIME_DIR=%t"
            # "WAYLAND_DISPLAY=wayland-1"
            "GBM_DEVICE=/dev/dri/renderD128"
          ]
          ++ (lib.mapAttrsToList (n: v: "${n}=${lib.escapeShellArg v}")
            config.programs.viture.serviceEnv));
      };
      # Don't auto launch
      # Install.WantedBy = [ "default.target" ];
    };
  };
}
