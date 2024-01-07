{ nixpkgs-unstable, ... }: {
  nixpkgs.overlays = [
    (final: prev: {
      unstable = nixpkgs-unstable.legacyPackages.${prev.system};
    })
  ];
}
