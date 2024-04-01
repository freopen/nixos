{ nixpkgs-unstable, ... }: {
  nixpkgs.overlays = [
    (final: prev: {
      unstable = nixpkgs-unstable.legacyPackages.${prev.system};
      xiaomi_miot = final.callPackage ../pkgs/xiaomi_miot.nix { };
    })
  ];
}
