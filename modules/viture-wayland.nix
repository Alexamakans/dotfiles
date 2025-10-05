{ config, lib, pkgs, ... }:

let
  cfg = config.programs.viture;

  # Tiny CLI to send one command to the socket (used by your keybinds).
  viturectl = pkgs.writeShellScriptBin "viturectl" ''
    #!/usr/bin/env bash
    set -euo pipefail
    if [[ $# -lt 1 ]]; then
      echo "usage: viturectl <align|push|pop|zoom-in|zoom-out|shift-left|shift-right|toggle-center-dot>" >&2
      exit 1
    fi
    cmd="$1"
    sock="${XDG_RUNTIME_DIR: -/tmp}/viture.sock"
    if [[ ! -S "$sock" ]]; then
      echo "socket not found at $sock" >&2
      exit 1
    fi
    exec ${pkgs.socat}/bin/socat - "UNIX-CONNECT:$sock" <<<"$cmd"
  '';

  # Resolve source according to the selected tracking mode.
  #
  # Mode "flake":
  #   - Reproducible. You add a flake input (see the comment in options below).
  #   - This module expects the source to be passed in via `cfg.flakeSrc`.
  #
  # Mode "impure":
  #   - Always tracks latest commit on a branch without changing hashes.
  #   - Requires `home-manager switch --impure` (or impure eval).
  #   - Not reproducible; builds change over time.
  impureSrc = lib.optionalAttrs (cfg.tracking.mode == "impure") (let
    url = if cfg.tracking.gitUrl != null then
      cfg.tracking.gitUrl
    else
      "https://github.com/${cfg.tracking.owner}/${cfg.tracking.repo}";
  in {
    src = builtins.fetchGit {
      url = url;
      # Use a branch or tag; "ref" is like `refs/heads/main` or just "main".
      # Shallow keeps eval snappy.
      ref = cfg.tracking.branch;
      shallow = true;
    };
    version = "branch-${cfg.tracking.branch}";
  });

  flakeSrc = lib.optionalAttrs (cfg.tracking.mode == "flake")
    (if cfg.flakeSrc == null then
      throw ''
        programs.viture.tracking.mode = "flake" but programs.viture.flakeSrc is null.
        Pass your input here from your top-level flake, e.g.:

          # flake.nix (top-level)
          inputs.viture-app.url = "github:OWNER/REPO/BRANCH";
          # then in your HM configuration:
          home-manager.extraSpecialArgs = { inherit inputs; };
          programs.viture.flakeSrc = inputs.viture-app;
      ''
    else {
      src = cfg.flakeSrc;
      version = "flake-branch";
    });

  resolved = if cfg.package != null then {
    src = null;
    version = "external";
  } else if (cfg.tracking.mode == "flake") then
    flakeSrc
  else if (cfg.tracking.mode == "impure") then
    impureSrc
  else {
    src = null;
    version = "unset";
  };

  # Build the binary with cmake, link against Wayland/EGL/GBM/DRM stack.
  viturePkg = if cfg.package != null then
    cfg.package
  else if resolved.src == null then
    null
  else
    pkgs.stdenv.mkDerivation {
      pname = "viture-ar-wayland-dmabuf";
      version = resolved.version;

      src = resolved.src;

      nativeBuildInputs =
        [ pkgs.cmake pkgs.pkg-config pkgs.wayland-scanner pkgs.patchelf ];

      buildInputs = with pkgs; [
        # Wayland/EGL/DMABUF stack (runtime + link)
        glfw-wayland
        wayland
        wayland-protocols
        libdrm
        gbm
        mesa
        libGL
        mesa_glu
        libxkbcommon
        egl-wayland
      ];

      # Ensure release build; CMakeLists should produce the binary
      configurePhase = ''
        runHook preConfigure
        cmake -B build -S . -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$out
        runHook postConfigure
      '';

      buildPhase = ''
        runHook preBuild
        cmake --build build -j$NIX_BUILD_CORES
        runHook postBuild
      '';

      installPhase = ''
        runHook preInstall

        mkdir -p $out/bin
        # Match the target name from the CMakeLists in our code drop:
        install -Dm755 build/viture_ar_desktop_wayland_dmabuf \
          $out/bin/viture_ar_desktop_wayland_dmabuf

        # If repo ships a prebuilt SDK .so, install and set RPATH so runtime finds it.
        if [ -f libs/libviture_one_sdk.so ]; then
          mkdir -p $out/lib
          install -Dm755 libs/libviture_one_sdk.so $out/lib/libviture_one_sdk.so
          ${pkgs.patchelf}/bin/patchelf \
            --set-rpath "$out/lib:${
              pkgs.lib.makeLibraryPath [
                pkgs.libGL
                pkgs.mesa
                pkgs.egl-wayland
                pkgs.gbm
                pkgs.libdrm
              ]
            }" \
            $out/bin/viture_ar_desktop_wayland_dmabuf
        fi

        runHook postInstall
      '';

      # Helpful during bringup
      dontStrip = lib.mkDefault false;
    };

  # Final path the service will ExecStart (prefer the Nix-built package)
  binPath = if viturePkg != null then
    "${viturePkg}/bin/viture_ar_desktop_wayland_dmabuf"
  else
    cfg.execPath;

in {
  options.programs.viture = {
    enable =
      lib.mkEnableOption "Viture XR (Wayland DMA-BUF) managed by Home Manager";

    # How to track the source:
    #   - mode = "flake": reproducible; you provide a flake input (cfg.flakeSrc).
    #   - mode = "impure": always-latest branch using builtins.fetchGit; requires impure eval.
    tracking = {
      mode = lib.mkOption {
        type = lib.types.enum [ "flake" "impure" ];
        default = "flake";
        description = ''
          Source tracking mode:
            - "flake": Reproducible. Set a flake input to github:OWNER/REPO/BRANCH and pass it via programs.viture.flakeSrc.
            - "impure": Always fetch latest of a branch (requires `home-manager switch --impure`). Not reproducible.
        '';
      };

      # For mode = "impure"
      owner = lib.mkOption {
        type = lib.types.str;
        default = "OWNER";
        description = "GitHub owner/org (impure mode).";
      };
      repo = lib.mkOption {
        type = lib.types.str;
        default = "REPO";
        description = "GitHub repo (impure mode).";
      };
      branch = lib.mkOption {
        type = lib.types.str;
        default = "main";
        description = "Branch to track (impure mode).";
      };

      # Optional: override full git URL (impure mode). If set, owner/repo are ignored.
      gitUrl = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description =
          "Optional full git URL for impure mode (https://... or ssh).";
      };
    };

    # For mode = "flake": pass the input from your top-level flake via extraSpecialArgs, e.g.
    #   inputs.viture-app.url = "github:OWNER/REPO/BRANCH";
    #   home-manager.extraSpecialArgs = { inherit inputs; };
    #   programs.viture.flakeSrc = inputs.viture-app;
    flakeSrc = lib.mkOption {
      type = lib.types.nullOr lib.types.raw;
      default = null;
      description = ''Flake input providing the source (mode = "flake").'';
    };

    # Alternatively, provide a prebuilt derivation/package directly.
    package = lib.mkOption {
      type = lib.types.nullOr lib.types.package;
      default = null;
      description = "Use this package instead of building from source.";
    };

    # Fallback (only used if package==null and no src resolved). Not recommended.
    execPath = lib.mkOption {
      type = lib.types.str;
      default =
        "${config.home.homeDirectory}/.local/bin/viture_ar_desktop_wayland_dmabuf";
      description = "Absolute path to the binary if not built by Nix.";
    };

    # Extra packages you want available in your user env.
    extraPackages = lib.mkOption {
      type = with lib.types; listOf package;
      default = [ ];
      description = "Additional packages to include alongside required deps.";
    };

    # Extra env for the user service, e.g. { WLR_NO_HARDWARE_CURSORS = "1"; }
    serviceEnvironment = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
      description = "Environment variables for the viture user service.";
    };
  };

  config = lib.mkIf cfg.enable {

    # Build/runtime deps + CLI
    home.packages = with pkgs;
      [
        # Runtime/GL/Wayland stack (also needed at build time)
        glfw-wayland
        wayland
        wayland-protocols
        wayland-scanner
        libdrm
        gbm
        mesa
        libGL
        mesa_glu
        libxkbcommon
        egl-wayland

        # Toolchain helpers (remove if building elsewhere)
        pkg-config
        cmake
        gcc
        gdb

        # Command-line helper
        viturectl
      ] ++ cfg.extraPackages;

    # Socket activation: %t == $XDG_RUNTIME_DIR
    systemd.user.sockets.viture = {
      Unit = { Description = "Viture command socket"; };
      Socket = {
        ListenStream = "%t/viture.sock";
        SocketMode = "0600";
      };
      Install = { WantedBy = [ "sockets.target" ]; };
    };

    # Service: starts when someone connects to viture.sock (or manually)
    systemd.user.services.viture = {
      Unit = {
        Description = "Viture XR service (Wayland DMA-BUF)";
        After = [ "viture.socket" ];
        Requires = [ "viture.socket" ];
      };
      Service = {
        ExecStart = binPath;
        Restart = "on-failure";

        # Ensure the service picks up the right runtime dir; merge user-provided env.
        Environment = lib.concatStringsSep " " ([ "XDG_RUNTIME_DIR=%t" ]
          ++ (lib.mapAttrsToList (n: v: "${n}=${lib.escapeShellArg v}")
            cfg.serviceEnvironment));
      };
      Install = { WantedBy = [ "default.target" ]; };
    };

    # NOTE (system-level): on some systems you may need group access to render nodes
    # users.users.<you>.extraGroups = [ "video" ];
    # This belongs in NixOS config, not Home Manager.

  };
}
