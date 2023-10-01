{ ... }: {
  networking = {
    hostName = "laptop";
    networkmanager = {
      enable = true;
      wifi.backend = "iwd";
      dns = "systemd-resolved";
    };
    nameservers =
      [ "1.1.1.1" "1.0.0.1" "2606:4700:4700::1111" "2606:4700:4700::1001" ];
    nftables.enable = true;
  };
  systemd.network.wait-online.enable = false;
  services.resolved = {
    enable = true;
    dnssec = "true";
    extraConfig = ''
      [Resolve]
      DNSOverTLS=yes
      MulticastDNS=no
    '';
  };
  services.avahi = {
    enable = true;
    nssmdns = true;
  };
  home-manager.users.freopen.services.network-manager-applet.enable = true;
}
