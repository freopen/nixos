{ pkgs, home-manager, agenix, ... }:
{
  imports = [
    agenix.nixosModule
    ./shell.nix
  ];
  nix.settings = {
    auto-optimise-store = true;
    sandbox = "relaxed";
  };
  nixpkgs.config.allowUnfree = true;
  boot.cleanTmpDir = true;
  zramSwap.enable = true;
  services.dbus.implementation = "broker";
  time.timeZone = "Europe/Zurich";
  i18n.defaultLocale = "en_US.UTF-8";
  system.stateVersion = "22.05";
}
