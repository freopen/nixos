{ config, pkgs, ... }: {
  age.secrets.fv0_ports = {
    file = ../secrets/fv0_ports.age;
    owner = "fp0";
    group = "fp0";
  };
  users.users.fp0 = {
    isSystemUser = true;
    group = "fp0";
  };
  users.groups.fp0 = { };
  systemd.services.fv0-ports = {
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      User = "fp0";
      Restart = "on-failure";
      RestartSec = "5";
      ExecStart = ''
        ${pkgs.openssh}/bin/ssh \
            -NTC \
            -o ServerAliveInterval=60 \
            -o ExitOnForwardFailure=yes \
            -o StrictHostKeyChecking=no \
            -R 127.0.0.1:19999:127.0.0.1:19999 \
            -i ${config.age.secrets.fv0_ports.path} \
            fv0-ports@fp0.freopen.org'';
    };
  };
}
