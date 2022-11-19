{
  description = "Freopen's NixOS config.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    fup.url = "github:gytis-ivaskevicius/flake-utils-plus";
    home-manager = {
      url = "github:nix-community/home-manager";
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

  outputs = { self, nixpkgs, fup, home-manager, agenix, chat_bot, chess_erdos, ... }@inputs:
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
          chat_bot.nixosModules.freopen_chat_bot
          ./server/chat_bot.nix
          chess_erdos.nixosModules.default
          ./server/chess_erdos.nix
        ];
      };
    };
}
