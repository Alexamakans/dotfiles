{ config, lib, pkgs, ... }:
let
  cfg = config.programs.pipOffline;
  defaultWheelhouse = "${config.home.homeDirectory}/wheelhouse";
in {
  options.programs.pipOffline = with lib; {
    enable = mkEnableOption "Force pip to install only from a local wheelhouse";
    wheelhousePath = mkOption {
      type = types.path;
      default = defaultWheelhouse;
      description =
        "Directory containing pre-downloaded wheels (your 'wheelhouse').";
    };
    extraFindLinks = mkOption {
      type = with types; listOf path;
      default = [ ];
      description =
        "Optional additional local directories to search for wheels.";
    };
    writePipConf = mkOption {
      type = types.bool;
      default = true;
      description = "Write ~/.config/pip/pip.conf to enforce offline installs.";
    };
  };

  config = lib.mkIf cfg.enable {
    # Environment variables (work even if pip.conf isn't written)
    home.sessionVariables = {
      PIP_NO_INDEX = "1";
      PIP_FIND_LINKS = lib.concatStringsSep " "
        ([ (toString cfg.wheelhousePath) ] ++ map toString cfg.extraFindLinks);
    };

    # Optional pip.conf to make it the default for all shells and tools
    xdg.configFile."pip/pip.conf" = lib.mkIf cfg.writePipConf {
      text = ''
        [global]
        no-index = true
        find-links = ${toString cfg.wheelhousePath}${
          lib.optionalString (cfg.extraFindLinks != [ ]) ("\n"
            + lib.concatStringsSep "\n"
            (map (p: "find-links = " + toString p) cfg.extraFindLinks))
        }
      '';
    };
  };
}
