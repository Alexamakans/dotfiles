{
  description = "NixOS + Home Manager (dotfiles)";

  inputs = {
    nixpkgs.url = "github:Alexamakans/nixpkgs/release-25.05";
    home-manager.url = "github:nix-community/home-manager/release-25.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";

    # renamed: no hyphen
    viturewayland.url = "github:Alexamakans/multimon-wayland/main";
  };

  outputs = { self, nixpkgs, home-manager, nix-flatpak, ... }@inputs:
    let
      defaultSystem = "x86_64-linux";
      pkgsFor = system:
        import nixpkgs {
          inherit system;
          config = { allowUnfree = true; };
        };

      mkHost = { host, user, system ? defaultSystem }:
        nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            ./hosts/${host}/configuration.nix
            nix-flatpak.nixosModules.nix-flatpak
            ({ ... }: {
              nix.settings.experimental-features = [ "nix-command" "flakes" ];
            })

            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;

              # pass inputs through so HM can access inputs.viturewayland
              home-manager.extraSpecialArgs = { inherit inputs; };

              home-manager.users.${user} = import ./home/${user}/home.nix;
            }
          ];
        };
    in {
      homeConfigurations.alex = home-manager.lib.homeManagerConfiguration {
        pkgs = pkgsFor defaultSystem;
        extraSpecialArgs = { inherit inputs; };
        modules = [ ./home.nix ];
      };

      nixosConfigurations = {
        alex = mkHost {
          host = "alex";
          user = "alex";
          system = defaultSystem;
        };
      };
    };
}
