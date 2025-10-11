{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: let
  dot = ../../files;

  # strip a leading "/" so the destination stays under $HOME
  normalize = p: lib.removePrefix "/" p;

  mkHomeFileRecursive = path: {
    home.file."${normalize path}" = {
      source = dot + "/${normalize path}";
      recursive = true;
    };
  };
in {
  # ← module-level field (NOT merged)
  imports = [
    ../../modules/viture-socket-service.nix
    ../../modules/viture-dynamic-display.nix

    # For internyet 2025
    # ../../modules/go-offline.nix
    # ../../modules/pip-offline.nix
  ];

  # ← everything you previously had in lib.mkMerge goes under config =
  config = lib.mkMerge [
    {
      programs.home-manager.enable = true;
      home.stateVersion = "25.05";

      home.packages = with pkgs; [
        file

        git
        gitleaks
        neovim
        ripgrep
        fzf
        jq
        yq-go
        dig
        nmap
        zip
        unzip
        gcc
        editorconfig-core-c
        qutebrowser
        shikane # Dynamic display output configuration
        discord
        zoxide
        gdb

        # golang
        go
        gopls
        gotools # e.g. goimports
        revive

        # c/c++
        cmake
        pkg-config
        clang-tools # provides clangd

        # python
        python3
        mypy

        # formatting/linting tools
        alejandra # nix
        shfmt
        shellcheck
        taplo # toml
        stylua
        luaPackages.luacheck
        mdformat

        pre-commit

        # used for rtl-sdr
        gqrx

        # certutil and other nssdb tools
        nssTools

        docker

        # test stuff temporary internyet
        # TODO: install when internet
        # libgcrypt
        # make
      ];

      home.sessionPath = ["${config.home.homeDirectory}/.local/bin"];
      home.sessionVariables = {
        EDITOR = "nvim";
        BROWSER = "qutebrowser";
        GOBIN = "${config.home.homeDirectory}/.local/bin";
      };

      programs.bash = {
        enable = true;
        initExtra = builtins.readFile "${dot}/.bashrc";
      };

      programs.waybar = {
        enable = true;
        settings = import ../../files/.config/waybar/config.nix;
        style = ../../files/.config/waybar/style.css;
      };

      home.file.".gitconfig".source = dot + "/.gitconfig";
      home.file.".gitconfig-ssh".source = dot + "/.gitconfig-ssh";

      xdg.configFile."qutebrowser/config.py".source =
        dot
        + "/.config/qutebrowser/config.py";
      xdg.configFile."qutebrowser/quickmarks".source =
        dot
        + "/.config/qutebrowser/quickmarks";

      programs.ssh = {
        enable = true;
        extraConfig = ''
          Host *
              IdentityAgent ~/.1password/agent.sock
        '';
      };

      programs.git = {
        enable = true;
        extraConfig = {
          gpg.format = "ssh";
          "gpg \"ssh\"".program = "${lib.getExe' pkgs._1password-gui "op-ssh-sign"}";
          commit.gpgsign = true;
          user.signingKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP6v8sgTuwobr8g+NnGZm72/E9xjgjXjy5IS3QWj3lga";
        };
      };

      programs.zoxide = {
        enable = true;
        enableBashIntegration = true;
        options = ["--cmd" "cd" "--hook" "pwd"];
      };
    }

    {
      programs.viture = {enable = true;};

      programs.vituredynamicdisplay = {
        enable = true;
        vendorId = "35ca";
        productId = "101d";
        laptopOutput = "eDP-1";
        headlessNames = ["headless-1" "headless-2" "headless-3"];
        headlessWorkspaces = [1 2 3];
        laptopWorkspace = 1;
        renameWorkspaces = true;
        workspaceNames = {
          "1" = "1-Laptop";
          "2" = "2-Docs";
          "3" = "3-Main";
          "4" = "4-AV";
        };
      };
    }

    {
      home.file.".config/hypr/conf.d/viture.conf".text = ''
        windowrulev2 = fullscreen, title:^(Viture AR \(Wayland DMA-BUF\))$
        windowrulev2 = fullscreen, initialtitle:^(Viture AR \(Wayland DMA-BUF\))$
      '';
    }

    (mkHomeFileRecursive ".config/hypr")
    (mkHomeFileRecursive ".config/waybar")
    (mkHomeFileRecursive ".config/shikane")
    (mkHomeFileRecursive ".config/kitty")
    (mkHomeFileRecursive ".config/nvim")
  ];
}
