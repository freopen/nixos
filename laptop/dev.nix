{ pkgs, agenix, ... }:
let
  afl-fuzz = pkgs.writeShellScriptBin "afl-fuzz" "cargo-afl afl fuzz $@";
in
{
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
  virtualisation.vmVariant.virtualisation.cores = 15;
  programs.nix-ld.enable = true;
  services.udev.extraRules = ''
    SUBSYSTEM=="usb", ATTRS{idVendor}=="0483", MODE="0664", GROUP="plugdev"
  '';
  environment = {
    variables = {
      CARGO_INSTALL_ROOT = "/home/freopen/.local";
    };
    localBinInPath = true;
  };
  home-manager.users.freopen = {
    home = {
      packages =
        [
          agenix.packages.x86_64-linux.default
          afl-fuzz
        ]
        ++ (with pkgs; [
          binaryen
          cargo-binutils
          cargo-insta
          cargo-make
          cargo-update
          clang
          nil
          nixcfg-apply
          unstable.nixd
          nixfmt-rfc-style
          nodePackages.pnpm
          protobuf
          rustup
          qmk
          tmux
          wasm-bindgen-cli
          wasm-pack
        ]);
      sessionVariables = {
        LIBCLANG_PATH = "${pkgs.libclang.lib}/lib";
      };
    };
    programs = {
      zsh.enable = true;
      vscode.enable = true;
    };
  };
}
