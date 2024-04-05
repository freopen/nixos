{ nixpkgs-unstable, ... }: {
  nixpkgs.overlays = [
    (final: prev: {
      unstable = import nixpkgs-unstable {
        system = prev.system;
        config.allowUnfree = true;
      };
      xiaomi_miot = final.callPackage ../pkgs/xiaomi_miot.nix { };
    })
  ];
}
