# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [./hardware-configuration.nix ../../modules/flatpak.nix];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  nix.settings.experimental-features = ["nix-command" "flakes"];

  networking.hostName = "alex"; # Define your hostname.
  # TODO: remove after internyet
  networking.nameservers = ["10.13.37.1"];

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Set your time zone.
  time.timeZone = "Europe/Stockholm";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "sv_SE.UTF-8";
    LC_IDENTIFICATION = "sv_SE.UTF-8";
    LC_MEASUREMENT = "sv_SE.UTF-8";
    LC_MONETARY = "sv_SE.UTF-8";
    LC_NAME = "sv_SE.UTF-8";
    LC_NUMERIC = "sv_SE.UTF-8";
    LC_PAPER = "sv_SE.UTF-8";
    LC_TELEPHONE = "sv_SE.UTF-8";
    LC_TIME = "sv_SE.UTF-8";
  };

  users.groups.plugdev = {};
  users.groups.alex = {};
  users.groups.docker = {};

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.alex = {
    isNormalUser = true;
    description = "alex";
    extraGroups = [
      "alex"
      "networkmanager"
      "wheel"
      "video"
      "input"

      "plugdev"
      "dialout" # for viture mostly, but for ttyACM0 generally

      "docker" # no need for `sudo docker`
    ];
  };

  services.udev.extraRules = ''
    # Viture Pro XR — hidraw interfaces
    SUBSYSTEM=="hidraw", KERNEL=="hidraw*", \
      ATTRS{idVendor}=="35ca", ATTRS{idProduct}=="101d", \
      MODE:="0660", GROUP:="plugdev", TAG+="uaccess", SYMLINK+="viture-%k"

    # Viture Pro XR — USB interface (good to tag the parent too)
    SUBSYSTEM=="usb", \
      ATTR{idVendor}=="35ca", ATTR{idProduct}=="101d", \
      MODE:="0660", GROUP:="plugdev", TAG+="uaccess"

    # Viture Pro XR — CDC ACM (serial) interface
    SUBSYSTEM=="tty", KERNEL=="ttyACM*", \
      ATTRS{idVendor}=="35ca", ATTRS{idProduct}=="101d", \
      MODE:="0660", GROUP:="dialout", TAG+="uaccess", SYMLINK+="viture-%k"

    # Viture Pro XR connect
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="35ca", ATTR{idProduct}=="101d", \
      TAG+="systemd", ENV{SYSTEMD_USER_WANTS}+="vituredynamicdisplay@add.service"

    # Viture Pro XR disconnect
    ACTION=="remove", SUBSYSTEM=="usb", ENV{ID_VENDOR_ID}=="35ca", ENV{ID_MODEL_ID}=="101d", \
      TAG+="systemd", ENV{SYSTEMD_USER_WANTS}+="vituredynamicdisplay@remove.service"
  '';

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --remember --cmd Hyprland";
      };
    };
  };

  services.printing.enable = false;
  services.avahi.enable = true;

  services.hardware.bolt.enable = true;

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [xdg-desktop-portal-gtk];
  };

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  networking.firewall.enable = true;
  # networking.firewall.allowedTCPPorts = [ 42069 ];

  networking.networkmanager.enable = true;
  services.blueman.enable = true;

  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true;

  fonts.packages =
    []
    ++ builtins.filter lib.attrsets.isDerivation
    (builtins.attrValues pkgs.nerd-fonts);

  # QOL env for Electron/Chromium apps on Wayland
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  profile.flatpak = {
    enable = true;
    portalBackend = "wlr";
    enableGtkPortal = true;
  };

  services.flatpak.packages = ["com.spotify.Client"];

  environment.systemPackages = with pkgs; [
    home-manager

    hyprland
    hyprpaper
    hyprlock
    hyprshot

    rofi-wayland
    kitty

    wl-clipboard
    grim
    slurp
    swappy

    networkmanagerapplet
    blueman
    pavucontrol
    brightnessctl

    btop-rocm # better htop

    openssl
    curl

    nodejs_22
    # npm -g equivalent:
    # nodePackages_latest.pnpm
    nodePackages_latest.prettier
  ];

  programs.hyprland = {
    enable = true;
    withUWSM = true;
    # Programs that need xwayland.enable = true;
    # - 1password
    xwayland.enable = true;
    #xwayland.enable = false;
  };

  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) ["1password" "1password-cli" "discord"];

  programs._1password.enable = true;
  programs._1password-gui.enable = true;
  programs._1password-gui.polkitPolicyOwners = ["alex"];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?

  virtualisation.docker.enable = true;
}
