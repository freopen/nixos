{ pkgs, home-manager, agenix, ... }:
{
  imports = [
    agenix.nixosModule
  ];
  nix.settings = {
    auto-optimise-store = true;
    sandbox = "relaxed";
  };
  nixpkgs.config.allowUnfree = true;
  boot.cleanTmpDir = true;
  zramSwap.enable = true;
  services.dbus.implementation = "broker";
  environment = {
    systemPackages = with pkgs; [
      vim
      curl
      git
    ];
  };
  time.timeZone = "Europe/Zurich";
  i18n.defaultLocale = "en_US.UTF-8";
  system.stateVersion = "22.05";
}
