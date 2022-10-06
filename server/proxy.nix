{ config, ... }:
{
  age.secrets.shadowsocks = {
    file = ../secrets/shadowsocks.age;
  };
  networking.firewall = {
    allowedTCPPorts = [ 443 ];
    allowedUDPPorts = [ 443 ];
  };
  services.shadowsocks = {
    enable = true;
    port = 443;
    passwordFile = config.age.secrets.shadowsocks.path;
  };
}
