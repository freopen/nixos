{ pkgs, config, ... }:
{
  age.secrets.cloudflared = {
    file = ../secrets/cloudflared.age;
    owner = "cloudflared";
    group = "cloudflared";
  };
  users.groups.cloudflared = { };
  users.users.cloudflared = {
    isSystemUser = true;
    group = "cloudflared";
  };
  systemd.services.cloudflared = {
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    serviceConfig = {
      User = "cloudflared";
      ExecStart = "${pkgs.cloudflared}/bin/cloudflared --cred-file ${config.age.secrets.cloudflared.path} --metrics localhost:8001 tunnel run 3450d3a3-bbff-4570-8719-c7ff62e60020";
    };
  };
}
