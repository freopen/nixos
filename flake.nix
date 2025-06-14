{
  description = "Freopen's NixOS config.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    impermanence.url = "github:nix-community/impermanence";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    chat_bot = {
      url = "github:freopen/chat-bot";
      # url = "/home/freopen/Projects/chat-bot";
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
        laptop = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = inputs;
          modules = [
            ./common
            ./laptop
          ];
        };
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
