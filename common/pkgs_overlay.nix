{ nixpkgs-unstable, ... }:
{
  nixpkgs.overlays = [
    (final: prev: {
      unstable = import nixpkgs-unstable {
        system = prev.stdenv.hostPlatform.system;
        config.allowUnfree = true;
      };
      fzf-preview = final.callPackage ../pkgs/fzf-preview.nix { };
    })
  ];
}
