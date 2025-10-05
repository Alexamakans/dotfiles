{ config, pkgs, lib, ... }:

let
  dot = ../../files;
  gobin = "${config.home.homeDirectory}/.local/bin";
  mkHomeFileRecursive = path: {
    home.file."${path}" = {
      source = dot + "${path}";
      recursive = true;
    };
  };
in lib.mkMerge [
  {
    # Let Home Manager install and manage itself.
    programs.home-manager.enable = true;

    imports = [ ../../modules/viture-socket-service.nix ];

    # This value determines the Home Manager release that your configuration is
    # compatible with. This helps avoid breakage when a new Home Manager release
    # introduces backwards incompatible changes.
    #
    # You should not change this value, even if you update Home Manager. If you do
    # want to update the value, then make sure to first check the Home Manager
    # release notes.
    home.stateVersion = "25.05"; # Please read the comment before changing.

    # The home.packages option allows you to install Nix packages into your
    # environment.
    home.packages = with pkgs; [
      git
      gitleaks

      neovim
      ripgrep
      fzf # fuzzy finder

      jq
      yq-go
      dig

      zip
      unzip

      gcc
      editorconfig-core-c

      python3

      qutebrowser # keyboard-first browser

      shikane # Dynamic display output configuration

      discord

      zoxide # better cd

      # golang development
      go
      gopls

      # c/c++ develeopment
      cmake
      pkg-config
    ];

    # Home Manager can also manage your environment variables through
    # 'home.sessionVariables'. These will be explicitly sourced when using a
    # shell provided by Home Manager. If you don't want to manage your shell
    # through Home Manager then you have to manually source 'hm-session-vars.sh'
    # located at either
    #
    #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
    #
    # or
    #
    #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
    #
    # or
    #
    #  /etc/profiles/per-user/alex/etc/profile.d/hm-session-vars.sh
    #

    home.sessionPath = [ gobin ];

    home.sessionVariables = {
      EDITOR = "nvim";
      BROWSER = "qutebrowser";
      GOBIN = gobin;
    };

    programs.bash = {
      enable = true;
      initExtra = builtins.readFile "${dot}/.bashrc";
    };

    home.file.".gitconfig".source = dot + "/.gitconfig";

    # qutebrowser:
    #   Manage specifics like config.py and quickmarks.
    #   Don't manage autoconfig.yml (qutebrowser rewrites it)
    #   In config.py, use:
    #     config.load_autoconfig(False)
    xdg.configFile."qutebrowser/config.py".source = dot
      + "/.config/qutebrowser/config.py";
    xdg.configFile."qutebrowser/quickmarks".source = dot
      + "/.config/qutebrowser/quickmarks";
  }

  (mkHomeFileRecursive "/.config/kitty")
  (mkHomeFileRecursive "/.config/hypr")
  (mkHomeFileRecursive "/.config/nvim")

  {
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
        "gpg \"ssh\"".program =
          "${lib.getExe' pkgs._1password-gui "op-ssh-sign"}";
        commit.gpgsign = true;

        user = {
          signingKey =
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP6v8sgTuwobr8g+NnGZm72/E9xjgjXjy5IS3QWj3lga";
        };
      };
    };

    programs.zoxide = {
      enable = true;
      enableBashIntegration = true;
      options = [ "--cmd" "cd" "--hook" "pwd" ];
    };

    programs.viture = {
      enable = true;
      tracking.mode = "flake";
      flakeSrc = inputs.viture;
    };
  }
]
