{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.programs.goOffline;
in {
  options.programs.goOffline = with lib; {
    enable =
      mkEnableOption
      "Force Go tooling to use local/vendor deps only (no network)";
    useVendor = mkOption {
      type = types.bool;
      default = true;
      description = ''
        If true, set GOFLAGS=-mod=vendor (requires ./vendor).
        If false, set GOFLAGS=-mod=readonly (uses cache only).
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    # Refuse network and checksum DB
    home.sessionVariables = {
      GOPROXY = "off";
      GOSUMDB = "off";
      GOFLAGS =
        if cfg.useVendor
        then "-mod=vendor"
        else "-mod=readonly";
    };
  };
}
