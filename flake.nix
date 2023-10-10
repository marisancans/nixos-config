{
  description = "example";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland.url = "github:hyprwm/Hyprland";
  };

  outputs = { self, nixpkgs, home-manager, hyprland, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

      lib = nixpkgs.lib;

    in {
      nixosConfigurations = {
        ma = lib.nixosSystem {
          inherit system;
          modules = [
           ./configuration.nix
            home-manager.nixosModules.home-manager {
              home-manager.useUserPackages = true;
              home-manager.users.ma = {
                imports = [
                  ./home.nix
                  hyprland.homeManagerModules.default
                ];
                wayland.windowManager.hyprland = {
                  enable = true;
#                   nvidiaPatches = true;
                };
              };
            }
          ];
        };
      };

    };
}

