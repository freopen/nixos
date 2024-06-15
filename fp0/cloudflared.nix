{ config, pkgs, ... }:
{
  age.secrets.cloudflared-fp0 = {
    file = ../secrets/cloudflared_fp0.age;
    owner = "cloudflared";
  };
  users.users.cloudflared = {
    group = "cloudflared";
    isSystemUser = true;
  };
  users.groups.cloudflared = { };
  systemd.services.cloudflared = {
    wantedBy = [ "multi-user.target" ];
    after = [
      "network.target"
      "network-online.target"
    ];
    wants = [
      "network.target"
      "network-online.target"
    ];
    serviceConfig = {
      User = "cloudflared";
      ExecStart = ''
        ${pkgs.cloudflared}/bin/cloudflared tunnel run \
          c60ce580-78f1-460f-9f46-53afd0096a5a
      '';
      EnvironmentFile = config.age.secrets.cloudflared-fp0.path;
      Type = "notify";
      Restart = "on-failure";
      RestartSec = "5s";
      TimeoutStartSec = "0";
    };
  };
}
