{ pkgs, fenix, agenix, ... }:
let
  rust = (with fenix.packages.x86_64-linux;
    (combine [
      complete.cargo
      complete.clippy
      complete.rust-src
      complete.rustc
      complete.rustfmt
      targets.wasm32-unknown-unknown.latest.rust-std
    ]));
  rust-completions = pkgs.symlinkJoin {
    name = "rust-completions";
    paths = [ rust ];
  };
in {
  programs.nix-ld.enable = true;
  home-manager.users.freopen = {
    nixpkgs.overlays = [ fenix.overlays.default ];
    home = {
      packages = with pkgs; [
        agenix.packages.x86_64-linux.default
        cargo-fuzz
        clang
        nil
        nixfmt
        rust
        rust-completions
        qmk
      ];
      sessionVariables = { LIBCLANG_PATH = "${pkgs.libclang.lib}/lib"; };
    };
    programs = {
      zsh.enable = true;
      vscode.enable = true;
    };
  };
}
