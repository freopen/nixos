{ ... }: {
  services.xserver = {
    enable = true;
    desktopManager.plasma5.enable = true;
    displayManager.sddm = {
      enable = true;
      wayland.enable = true;
      autoNumlock = true;
    };
  };
  home-manager.users.freopen.services.kdeconnect.enable = true;
  networking.firewall.allowedTCPPortRanges = [{
    from = 1714;
    to = 1764;
  }];
  networking.firewall.allowedUDPPortRanges = [{
    from = 1714;
    to = 1764;
  }];
}
