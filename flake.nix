{
  description = "Freopen's NixOS config.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
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

  outputs = { self, nixpkgs, agenix, ... }@inputs: {
    nixosConfigurations = {
      laptop = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = inputs;
        modules = [ ./common ./laptop ];
      };
      server = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = inputs;
        modules = [ ./common ./server ];
      };
    };
    devShells.x86_64-linux.default =
      let pkgs = nixpkgs.legacyPackages.x86_64-linux;
      in pkgs.mkShell {
        nativeBuildInputs = with pkgs; [
          nil
          nixfmt
          agenix.defaultPackage.x86_64-linux
        ];
      };
  };
}
