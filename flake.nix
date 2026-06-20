{
  description = "Freopen's NixOS config.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    impermanence.url = "github:nix-community/impermanence";
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    chess_erdos = {
      url = "github:freopen/chess-erdos";
      # url = "/home/freopen/Projects/chess-erdos";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { nixpkgs, ... }@flakeInputs:
    let
      inputs = flakeInputs // {
        const = import ./const.nix;
      };
    in
    {
      nixosConfigurations = {
        fv2 = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = inputs;
          modules = [
            ./common
            ./fv2
          ];
        };
      };
    };
}
