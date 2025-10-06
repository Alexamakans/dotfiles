{ config, pkgs, lib, inputs, ... }:

let
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
  imports = [ ../../modules/viture-socket-service.nix ];

  # ← everything you previously had in lib.mkMerge goes under config =
  config = lib.mkMerge [
    {
      programs.home-manager.enable = true;
      home.stateVersion = "25.05";

      home.packages = with pkgs; [
        git
        gitleaks
        neovim
        ripgrep
        fzf
        jq
        yq-go
        dig
        zip
        unzip
        gcc
        editorconfig-core-c
        python3
        qutebrowser
        shikane
        discord
        zoxide
        gdb
        # golang
        go
        gopls
        # c/c++
        cmake
        pkg-config
        clang-tools # provides clangd
      ];

      home.sessionPath = [ "${config.home.homeDirectory}/.local/bin" ];
      home.sessionVariables = {
        EDITOR = "nvim";
        BROWSER = "qutebrowser";
        GOBIN = "${config.home.homeDirectory}/.local/bin";
      };

      programs.bash = {
        enable = true;
        initExtra = builtins.readFile "${dot}/.bashrc";
      };

      home.file.".gitconfig".source = dot + "/.gitconfig";

      xdg.configFile."qutebrowser/config.py".source = dot
        + "/.config/qutebrowser/config.py";
      xdg.configFile."qutebrowser/quickmarks".source = dot
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
          "gpg \"ssh\"".program =
            "${lib.getExe' pkgs._1password-gui "op-ssh-sign"}";
          commit.gpgsign = true;
          user.signingKey =
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP6v8sgTuwobr8g+NnGZm72/E9xjgjXjy5IS3QWj3lga";
        };
      };

      programs.zoxide = {
        enable = true;
        enableBashIntegration = true;
        options = [ "--cmd" "cd" "--hook" "pwd" ];
      };

      programs.viture = { enable = true; };
    }

    (mkHomeFileRecursive "/.config/kitty")
    (mkHomeFileRecursive "/.config/hypr")
    (mkHomeFileRecursive "/.config/nvim")
  ];
}
