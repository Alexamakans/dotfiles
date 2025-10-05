{ lib, pkgs, config, ... }:

let
  inherit (lib) mkIf mkOption mkEnableOption types optional;
  cfg = config.profile.flatpak;
in {
  options.profile.flatpak = {
    enable = mkEnableOption "Flatpak with Flathub and xdg-desktop-portals";

    portalBackend = mkOption {
      type = types.enum [ "wlr" "gnome" "kde" ];
      default = "wlr";
      description = "xdg-desktop-portal backend to use.";
    };

    # GTK portal helps with file pickers/printing dialogs
    enableGtkPortal = mkOption {
      type = types.bool;
      default = true;
      description = "Include xdg-desktop-portal-gtk in extraPortals.";
    };

    enableFlathub = mkOption {
      type = types.bool;
      default = true;
      description = "Add the Flathub remote.";
    };
  };

  config = mkIf cfg.enable {
    services.flatpak.enable = true;

    services.flatpak.remotes = mkIf cfg.enableFlathub [{
      name = "flathub";
      location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
    }];

    xdg.portal.enable = true;
    xdg.portal.extraPortals =
      (optional (cfg.portalBackend == "wlr") pkgs.xdg-desktop-portal-wlr)
      ++ (optional (cfg.portalBackend == "gnome") pkgs.xdg-desktop-portal-gnome)
      ++ (optional (cfg.portalBackend == "kde") pkgs.xdg-desktop-portal-kde)
      ++ (optional cfg.enableGtkPortal pkgs.xdg-desktop-portal-gtk);

    environment.systemPackages = [ pkgs.flatpak ];

    security.polkit.enable = lib.mkDefault true;
  };
}
