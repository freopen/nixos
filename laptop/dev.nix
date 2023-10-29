{ pkgs, fenix, agenix, ... }:
let
  rust = (with fenix.packages.x86_64-linux;
    (combine [
      complete.cargo
      complete.clippy
      complete.rust-src
      complete.rustc
      complete.rustfmt
      complete.llvm-tools-preview
      targets.wasm32-unknown-unknown.latest.rust-std
      targets.thumbv6m-none-eabi.latest.rust-std
    ]));
  rust-completions = pkgs.symlinkJoin {
    name = "rust-completions";
    paths = [ rust ];
  };
in {
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
  programs.nix-ld.enable = true;
  services.udev.extraRules = ''
    SUBSYSTEM=="usb", ATTRS{idVendor}=="0483", MODE="0664", GROUP="plugdev"
  '';
  home-manager.users.freopen = {
    nixpkgs.overlays = [ fenix.overlays.default ];
    home = {
      packages = with pkgs; [
        agenix.packages.x86_64-linux.default
        cargo-binutils
        cargo-bolero
        cargo-insta
        cargo-make
        clang
        nil
        nixfmt
        probe-rs
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
