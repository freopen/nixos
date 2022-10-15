{
  description = "Freopen's NixOS config.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    fup = {
      url = "github:gytis-ivaskevicius/flake-utils-plus";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, fup, home-manager, agenix, ... }@inputs:
    fup.lib.mkFlake {
      inherit self inputs;

      channelsConfig.allowUnfree = true;

      hostDefaults = {
        system = "x86_64-linux";
        modules = [
          agenix.nixosModule
          home-manager.nixosModules.home-manager
          ./common
        ];
      };

      hosts = {
        laptop.modules = [
          ./hosts/laptop.nix
          ./desktop
        ];
        server.modules = [
          ./hosts/server.nix
          ./server/monitoring.nix
          ./server/proxy.nix
          ./server/wireguard
        ];
      };
    };
}
