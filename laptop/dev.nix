{ pkgs, fenix, agenix, ... }: {
  programs.nix-ld.enable = true;
  home-manager.users.freopen = {
    nixpkgs.overlays = [ fenix.overlays.default ];
    home = {
      packages = with pkgs; [
        agenix.packages.x86_64-linux.default
        clang
        nil
        nixfmt
        (with fenix.packages.x86_64-linux;
          (combine [
            complete.cargo
            complete.clippy
            complete.rust-src
            complete.rustc
            complete.rustfmt
            targets.wasm32-unknown-unknown.latest.rust-std
          ]))
      ];
      sessionVariables = { LIBCLANG_PATH = "${pkgs.libclang.lib}/lib"; };
    };
    programs = {
      zsh.enable = true;
      vscode.enable = true;
    };
  };
}
