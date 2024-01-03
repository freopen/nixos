{ pkgs, agenix, ... }: {
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
  programs.nix-ld.enable = true;
  services.udev.extraRules = ''
    SUBSYSTEM=="usb", ATTRS{idVendor}=="0483", MODE="0664", GROUP="plugdev"
  '';
  home-manager.users.freopen = {
    home = {
      packages = with pkgs; [
        agenix.packages.x86_64-linux.default
        binaryen
        cargo-binutils
        cargo-insta
        cargo-make
        clang
        nil
        nixfmt
        nodePackages.pnpm
        protobuf
        rustup
        qmk
        wasm-bindgen-cli
        wasm-pack
      ];
      sessionVariables = { LIBCLANG_PATH = "${pkgs.libclang.lib}/lib"; };
    };
    programs = {
      zsh.enable = true;
      vscode.enable = true;
    };
  };
}
