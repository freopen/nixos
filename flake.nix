{
  description = "Freopen's NixOS config.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    fup.url = "github:gytis-ivaskevicius/flake-utils-plus";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, fup, home-manager, ... }@inputs: 
    fup.lib.mkFlake {
      inherit self inputs;

      channelsConfig.allowUnfree = true;

      hostDefaults = {
        system = "x86_64-linux";
        modules = [
          home-manager.nixosModules.home-manager
          ./common
        ];
      };

      hosts.laptop = {
        modules = [
          ./hosts/laptop.nix
          ./desktop
        ];
      };
    };
}
