{ pkgs, ... }:
{
  environment = {
    systemPackages = with pkgs; [
      vim
      curl
      git
    ];
  };
  time.timeZone = "Europe/Zurich";
  i18n.defaultLocale = "en_US.UTF-8";
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  system.stateVersion = "22.05";
}
