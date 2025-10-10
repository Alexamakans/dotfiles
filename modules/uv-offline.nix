{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.programs.uvOffline;
  defaultWheelhouse = "${config.home.homeDirectory}/wheelhouse";
in {
  options.programs.uvOffline = with lib; {
    enable = mkEnableOption "Force uv to operate offline and only from local wheelhouse(s)";

    wheelhousePath = mkOption {
      type = types.path;
      default = defaultWheelhouse;
      description = "Directory containing pre-downloaded wheels / sdists.";
    };

    extraFindLinks = mkOption {
      type = with types; listOf path;
      default = [];
      description = "Additional local directories to search for wheels/sdists.";
    };

    writeUvToml = mkOption {
      type = types.bool;
      default = true;
      description = "Write ~/.config/uv/uv.toml to enforce offline + no-index + find-links.";
    };

    # Optional: also prevent uv from auto-downloading Python runtimes.
    forbidPythonDownloads = mkOption {
      type = types.bool;
      default = true;
      description = "Set python-downloads = \"never\" so uv won't fetch Python builds.";
    };
  };

  config = lib.mkIf cfg.enable {
    # Environment variables: take effect even without a config file.
    home.sessionVariables = {
      # Disables all network access (“use only cached/local files”).
      # CLI equivalent: `uv ... --offline`
      UV_OFFLINE = "1"; # docs: uv CLI `--offline` / env `UV_OFFLINE`
    };

    # uv configuration file to harden behavior across all commands
    xdg.configFile."uv/uv.toml" = lib.mkIf cfg.writeUvToml {
      text = let
        findLinks =
          lib.concatStringsSep ", "
          (map (p: "\"${toString p}\"")
            ([cfg.wheelhousePath] ++ cfg.extraFindLinks));
        pyDl = lib.optionalString cfg.forbidPythonDownloads ''
          python-downloads = "never"
        '';
      in ''
        [tool.uv]
        # Never hit the network; rely only on cache and local files.
        offline = true
        # Ignore PyPI or any registry entirely; resolve only from direct files/links.
        no-index = true
        # Where to look for local wheels / sdists (flat directory of *.whl / *.tar.gz / *.zip)
        find-links = [ ${findLinks} ]
        ${pyDl}
      '';
    };
  };
}
