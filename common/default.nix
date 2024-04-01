{ pkgs, agenix, ... }: {
  imports = [
    ../modules
    agenix.nixosModules.default
    ./build_cache.nix
    ./shell.nix
    ./pkgs_overlay.nix
  ];
  systemd.tmpfiles.rules = [ "L+ /etc/nixPath - - - - ${pkgs.path}" ];
  nix = {
    nixPath = [ "nixpkgs=/etc/nixPath" ];
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
    settings = {
      auto-optimise-store = true;
      sandbox = "relaxed";
      experimental-features = [ "nix-command" "flakes" ];
      log-lines = 25;
      min-free = 128 * 1000 * 1000;
      max-free = 1000 * 1000 * 1000;
      builders-use-substitutes = true;
      substituters =
        [ "https://nix-community.cachix.org" "https://numtide.cachix.org" ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ik6cQjb41X0iXVXeHigGmycPPE="
      ];
    };
    daemonCPUSchedPolicy = "idle";
    daemonIOSchedClass = "idle";
    daemonIOSchedPriority = 7;
    extraOptions = ''
      keep-outputs = true
      keep-derivations = true
    '';
  };
  nixpkgs.config.allowUnfree = true;
  networking.firewall.logRefusedConnections = false;
  boot.tmp.cleanOnBoot = true;
  zramSwap = {
    enable = true;
    memoryPercent = 100;
  };
  services.dbus.implementation = "broker";
  i18n.defaultLocale = "en_US.UTF-8";
  system = {
    stateVersion = "22.05";
    activationScripts.diff = ''
      if [[ -e /run/current-system ]]; then
        ${pkgs.nix}/bin/nix store diff-closures /run/current-system "$systemConfig"
      fi
    '';
  };
}
