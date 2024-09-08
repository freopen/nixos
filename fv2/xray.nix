{ config, pkgs, ... }:
{
  age.secrets.xray.file = ../secrets/xray.age;
  networking.firewall.allowedTCPPorts = [
    80
    443
  ];
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
