{ nixpkgs-unstable, ... }:
{
  nixpkgs.overlays = [
    (final: prev: {
      unstable = import nixpkgs-unstable {
        system = prev.system;
        config.allowUnfree = true;
      };
      xiaomi_miot = final.callPackage ../pkgs/xiaomi_miot.nix { };
      nixcfg-apply = final.callPackage ../pkgs/nixcfg-apply.nix { };
      fzf-preview = final.callPackage ../pkgs/fzf-preview.nix { };
    })
  ];
}
