{ config, pkgs, ... }:
{
  age.secrets.xray.file = ../secrets/xray.age;
  networking.firewall.allowedTCPPorts = [
    80
    443
  ];
  services.nginx = {
    enable = true;
    logError = "syslog:server=unix:/dev/log";
    commonHttpConfig = ''
      access_log syslog:server=unix:/dev/log;
    '';
    virtualHosts."photos.freopen.org".locations."/".return = "301 https://photos.freopen.org";
  };
  systemd.services.xray = {
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    restartTriggers = [ config.age.secrets.xray.file ];
    serviceConfig = {
      DynamicUser = true;
      LoadCredential = "xray.json:${config.age.secrets.xray.path}";
      ExecStart = "${pkgs.xray}/bin/xray -config %d/xray.json";
      CapabilityBoundingSet = "CAP_NET_ADMIN CAP_NET_BIND_SERVICE";
      AmbientCapabilities = "CAP_NET_ADMIN CAP_NET_BIND_SERVICE";
      NoNewPrivileges = true;
    };
  };
}
