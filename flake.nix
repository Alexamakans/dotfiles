{
  description = "NixOS + Home Manager (dotfiles)";

  inputs = {
    nixpkgs.url = "github:Alexamakans/nixpkgs/release-25.05";
    home-manager.url = "github:nix-community/home-manager/release-25.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";
  };

  outputs = { self, nixpkgs, home-manager, nix-flatpak, ... }:
    let
      mkHost = { host, user, system }:
        nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            # Per-host NixOS config (should import hardware-configuration.nix)
            ./hosts/${host}/configuration.nix
            nix-flatpak.nixosModules.nix-flatpak

            ({ ... }: {
              nix.settings.experimental-features = [ "nix-command" "flakes" ];
            })

            # Wire in Home Manager as a NixOS module
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.${user} = import ./home/${user}/home.nix;
            }
          ];
        };
    in {
      nixosConfigurations = {
        alex = mkHost {
          host = "alex";
          user = "alex";
          system = "x86_64-linux";
        };
      };
    };
}
