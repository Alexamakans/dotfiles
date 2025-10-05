{ config, lib, pkgs, inputs, ... }:

let
  # Use the packaged app from your project input
  viturePkg = inputs.viture.packages.${pkgs.system}.default;

  viturectl = pkgs.writeShellScriptBin "viturectl" ''
    #!/usr/bin/env bash
    set -euo pipefail
    if [[ $# -lt 1 ]]; then
      echo "usage: viturectl <align|push|pop|zoom-in|zoom-out|shift-left|shift-right|toggle-center-dot>" >&2
      exit 1
    fi
    exec ${pkgs.socat}/bin/socat - "UNIX-CONNECT:${
      "$"
    }{XDG_RUNTIME_DIR:-/tmp}/viture.sock" <<<"$1"
  '';
in {
  options.programs.viture = {
    enable = lib.mkEnableOption "Viture XR socket+service";
    serviceEnv = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
      description = "Extra env for the viture user service.";
    };
  };

  config = lib.mkIf config.programs.viture.enable {
    # Only the runtime bits you might want in your user profile
    home.packages = [ viturePkg viturectl pkgs.socat ];

    # Socket activation in the user session
    systemd.user.sockets.viture = {
      Unit.Description = "Viture command socket";
      Socket = {
        ListenStream = "%t/viture.sock";
        SocketMode = "0600";
      };
      Install.WantedBy = [ "sockets.target" ];
    };

    # Service: starts on first viturectl, or manually
    systemd.user.services.viture = {
      Unit = {
        Description = "Viture XR service";
        After = [ "viture.socket" ];
        Requires = [ "viture.socket" ];
      };
      Service = {
        ExecStart = "${viturePkg}/bin/viture_ar_desktop_wayland_dmabuf";
        Restart = "on-failure";
        Environment = lib.concatStringsSep " " ([ "XDG_RUNTIME_DIR=%t" ]
          ++ (lib.mapAttrsToList (n: v: "${n}=${lib.escapeShellArg v}")
            config.programs.viture.serviceEnv));
      };
      Install.WantedBy = [ "default.target" ];
    };
  };
}
