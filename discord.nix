# /etc/nixos/flake.nix
# Your configuration will probably look different; this is just an example!
{
  description = "Example NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    discord-overlay.url = "github:InternetUnexplorer/discord-overlay";
    discord-overlay.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, discord-overlay }: {
    nixosConfigurations.example = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ({ ... }: { nixpkgs.overlays = [ discord-overlay.overlays.default ]; })
        ./configuration.nix
      ];
    };
  };
}
