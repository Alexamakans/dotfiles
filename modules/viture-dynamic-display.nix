{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.programs.vituredynamicdisplay;
  inherit
    (lib)
    mkEnableOption
    mkOption
    mkIf
    types
    concatStringsSep
    optionalString
    ;

  # Helper: turn an attrset of workspace->name into a hyprctl batch
  mkRenameBatch = names: let
    lines =
      lib.mapAttrsToList (ws: nm: "dispatch renameworkspace ${ws} ${nm};")
      names;
  in
    concatStringsSep " " lines;

  # Common shell used by add/remove
  scriptCommon = pkgs.writeShellScript "vituredynamicdisplay-common" ''
    set -euo pipefail

    LAPTOP="${cfg.laptopOutput}"
    H_NAMES=(${concatStringsSep " " cfg.headlessNames})

    # JSON tools
    JQ="${pkgs.jq}/bin/jq"

    present() {
      hyprctl -j monitors all | "$JQ" -r '.[].name' | grep -xq "$1"
    }

    # Create headless outputs if missing
    ensure_headless() {
      for h in "''${H_NAMES[@]}"; do
        present "$h" || hyprctl output create headless "$h"
      done
    }

    # Remove headless outputs if present
    drop_headless() {
      for h in "''${H_NAMES[@]}"; do
        if present "$h"; then
          hyprctl output remove "$h" || true
        fi
      done
    }

    # Move WS i -> headless i (paired by index), and laptop WS
    map_to_headless() {
      # Workspaces and headless names must have same length for the headless side.
      ${
      lib.concatMapStrings (i: let
        ws = builtins.elemAt cfg.headlessWorkspaces i;
        h = builtins.elemAt cfg.headlessNames i;
      in ''
        hyprctl dispatch moveworkspacetomonitor ${toString ws} "${h}";
      '') (lib.range 0 (builtins.length cfg.headlessWorkspaces - 1))
    }
      hyprctl dispatch moveworkspacetomonitor ${
      toString cfg.laptopWorkspace
    } "$LAPTOP"
    }

    map_all_to_laptop() {
      ${
      concatStringsSep "\n" (map (w: ''
        hyprctl dispatch moveworkspacetomonitor ${toString w} "$LAPTOP"
      '') (cfg.headlessWorkspaces ++ [cfg.laptopWorkspace]))
    }
    }

    wait_for_outputs() {
      # wait up to ~1s for each headless to appear
      for h in "''${H_NAMES[@]}"; do
        for _ in $(seq 1 10); do
          if present "$h"; then break; fi
          sleep 0.1
        done
      done
    }

    reassert_mapping() {
      # try a few times to beat any post-hotplug reshuffle
      for _ in $(seq 1 5); do
        ${
      lib.concatMapStrings (i: let
        ws = builtins.elemAt cfg.headlessWorkspaces i;
        h = builtins.elemAt cfg.headlessNames i;
      in ''
        hyprctl dispatch moveworkspacetomonitor ${toString ws} "${h}";'')
      (lib.range 0 (builtins.length cfg.headlessWorkspaces - 1))
    }
        hyprctl dispatch moveworkspacetomonitor ${
      toString cfg.laptopWorkspace
    } "$LAPTOP"
        sleep 0.05
      done
    }


    rename_workspaces() {
      ${
      optionalString cfg.renameWorkspaces ''
        hyprctl --batch "${mkRenameBatch cfg.workspaceNames}"
      ''
    }
    }
  '';

  scriptAdd = pkgs.writeShellScript "vituredynamicdisplay-add" ''
    set -euo pipefail
    source "${scriptCommon}"
    ensure_headless
    wait_for_outputs
    map_to_headless
    reassert_mapping
    rename_workspaces
    hyprctl --batch "dispatch focusmonitor $LAPTOP; dispatch workspace ${toString cfg.laptopWorkspace}"
  '';

  scriptRemove = pkgs.writeShellScript "vituredynamicdisplay-remove" ''
    set -euo pipefail
    source "${scriptCommon}"
    map_all_to_laptop
    drop_headless
    rename_workspaces
  '';

  # User-space USB watcher: no root/udev rules required.
  # Listens to udev events and triggers add/remove handlers.
  scriptMonitor = pkgs.writeShellScript "vituredynamicdisplay-monitor" ''
        set -euo pipefail

        VENDOR="${cfg.vendorId}"
        PRODUCT="${cfg.productId}"

        # Quick check of current presence at startup via sysfs
        device_present_now() {
          for d in /sys/bus/usb/devices/*; do
            [ -r "$d/idVendor" ] || continue
            [ -r "$d/idProduct" ] || continue
            v=$(cat "$d/idVendor") || true
            p=$(cat "$d/idProduct") || true
            if [ "$v" = "$VENDOR" ] && [ "$p" = "$PRODUCT" ]; then
              return 0
            fi
          done
          return 1
        }

        # Debounced triggers so rapid event bursts don’t double-fire
        do_add()    {
          systemctl --user start viture.socket || true;
          systemd-run --user --quiet --collect --property=Type=oneshot "${scriptAdd}";
          systemctl --user start viture.service;
        }
        do_remove() {
          systemctl --user stop viture.service || true;
          systemd-run --user --quiet --collect --property=Type=oneshot "${scriptRemove}";
          systemctl --user stop viture.socket || true;

          if systemctl --user is-active quiet viture.service; then
            systemctl --user kill -s SIGKILL viture.service || true;
          fi
        }

        # Initial sync to current state
        if device_present_now; then
          do_add
        else
          do_remove
        fi

        # Follow udev events (readable as user), react to presence flips
    present_prev=0
    if device_present_now; then present_prev=1; fi

    ${pkgs.coreutils}/bin/stdbuf -oL \
      ${pkgs.systemd}/bin/udevadm monitor --udev --subsystem-match=usb --property |
    {
      act=""; v=""; p=""; devpath=""
      while IFS= read -r line; do
        case "$line" in
          UDEV*" add "* )    act=add ;;
          UDEV*" remove "* ) act=remove ;;
          DEVPATH=* )        devpath="''${line#DEVPATH=}" ;;
          ID_VENDOR_ID=* )   v="''${line#ID_VENDOR_ID=}" ;;
          ID_MODEL_ID=* )    p="''${line#ID_MODEL_ID=}" ;;
          "" )
            # decide presence using fast sysfs check (works even when remove lacks IDs)
            present_now=0
            if device_present_now; then present_now=1; fi

            if [ "$present_now" -ne "$present_prev" ]; then
              if [ "$present_now" -eq 1 ]; then
                do_add
              else
                do_remove
              fi
              present_prev=$present_now
            fi

            # reset block vars
            act=""; v=""; p=""; devpath=""
            ;;
        esac
      done
    }
  '';
in {
  options.programs.vituredynamicdisplay = {
    enable =
      mkEnableOption
      "USB-driven headless outputs + workspace mapping for Hyprland (user-space)";

    vendorId = mkOption {
      type = types.str;
      default = "35ca";
      description = "USB idVendor that toggles headless mode.";
    };

    productId = mkOption {
      type = types.str;
      default = "101d";
      description = "USB idProduct that toggles headless mode.";
    };

    laptopOutput = mkOption {
      type = types.str;
      default = "eDP-1";
      description = "Hyprland name of the laptop panel.";
    };

    headlessNames = mkOption {
      type = types.listOf types.str;
      default = ["headless-1" "headless-2" "headless-3"];
      description = "Names for Hyprland headless outputs to create/remove.";
    };

    headlessWorkspaces = mkOption {
      type = types.listOf types.int;
      default = [1 2 3];
      description = "Workspace numbers to pin to the headless outputs (paired by index with headlessNames).";
    };

    laptopWorkspace = mkOption {
      type = types.int;
      default = 4;
      description = "Workspace number dedicated to the laptop output.";
    };

    renameWorkspaces = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to rename workspaces when mapping changes.";
    };

    workspaceNames = mkOption {
      type = types.attrsOf types.str;
      default = {
        "1" = "Headless-A";
        "2" = "Headless-B";
        "3" = "Headless-C";
        "4" = "Laptop";
      };
      description = "Names to assign to workspaces (keys are workspace numbers as strings).";
    };
  };

  config = mkIf cfg.enable {
    # tools used by the scripts
    home.packages = [pkgs.jq pkgs.coreutils pkgs.systemd pkgs.gawk];

    # Long-running user-space watcher (no root, no udev rules)
    systemd.user.services.vituredynamicdisplay-monitor = {
      Unit = {
        Description = "Monitor USB ${cfg.vendorId}:${cfg.productId} and toggle Hyprland headless mode";
        PartOf = ["graphical-session.target"];
        After = ["graphical-session.target"];
      };
      Service = {
        ExecStart = "${scriptMonitor}";
        Restart = "on-failure";
        RestartSec = 1;
        # Ensure we inherit the Hyprland IPC env vars from the session
        # The file is written by an exec-once in %t/hypr/hyprland.conf
        EnvironmentFile = "%t/hypr/hyprland.env";
      };
      Install = {WantedBy = ["graphical-session.target"];};
    };

    # Convenience oneshot units so you can trigger manually if you want:
    systemd.user.services.vituredynamicdisplay-add = {
      Unit.Description = "Force-enable headless outputs and mapping";
      Service = {
        Type = "oneshot";
        ExecStart = "${scriptAdd}";
      };
      Install.WantedBy = ["default.target"];
    };
    systemd.user.services.vituredynamicdisplay-remove = {
      Unit.Description = "Force-disable headless outputs and mapping";
      Service = {
        Type = "oneshot";
        ExecStart = "${scriptRemove}";
      };
      Install.WantedBy = ["default.target"];
    };
  };
}
