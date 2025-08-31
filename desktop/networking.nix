{ ... }:
{
  networking = {
    networkmanager = {
      enable = true;
      wifi.backend = "iwd";
      dns = "systemd-resolved";
    };
    nameservers = [ ]; # Use DHCP provided DNS to deal with captive portals
    nftables.enable = true;
  };
  systemd.network.wait-online.enable = false;
  services.resolved = {
    enable = true;
    dnssec = "allow-downgrade";
    extraConfig = ''
      [Resolve]
      DNSOverTLS=opportunistic
      MulticastDNS=no
    '';
  };
  services.avahi = {
    enable = true;
    nssmdns4 = true;
  };
}
