{ ... }: {
  networking = {
    hostName = "laptop";
    networkmanager = {
      enable = true;
      wifi.backend = "iwd";
      dns = "systemd-resolved";
    };
    wireless.iwd.enable = true;
    nameservers =
      [ "1.1.1.1" "1.0.0.1" "2606:4700:4700::1111" "2606:4700:4700::1001" ];
  };
  systemd.network.wait-online.enable = false;
  services.resolved = {
    enable = true;
    dnssec = "true";
    extraConfig = ''
      [Resolve]
      DNSOverTLS=yes
    '';
  };

  home-manager.users.freopen.services.network-manager-applet.enable = true;
}
