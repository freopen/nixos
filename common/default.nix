{ pkgs, home-manager, agenix, ... }: {
  imports = [ agenix.nixosModule ./shell.nix ./build_cache.nix ];
  nix = {
    settings = {
      auto-optimise-store = true;
      sandbox = "relaxed";
      experimental-features = [ "nix-command" "flakes" ];
    };
    extraOptions = ''
      keep-outputs = true
      keep-derivations = true
    '';
  };
  nixpkgs.config.allowUnfree = true;
  boot.cleanTmpDir = true;
  zramSwap = {
    enable = true;
    memoryPercent = 100;
  };
  services.dbus.implementation = "broker";
  time.timeZone = "Europe/Zurich";
  i18n.defaultLocale = "en_US.UTF-8";
  system.stateVersion = "22.05";
}
