{ ... }:
{
  users.users.ghost = {
    isSystemUser = true;
    createHome = true;
    home = "/var/lib/ghost";
    autoSubUidGidRange = true;
    group = "ghost";
    linger = false;
  };
  users.groups.ghost = { };
  environment.persistence."/nix/persist".directories = [
    {
      directory = "/var/lib/ghost";
      user = "ghost";
      group = "ghost";
      mode = "0750";
    }
  ];
  virtualisation = {
    containers.enable = true;
    podman = {
      enable = true;
      autoPrune.enable = true;
    };
    oci-containers.containers.ghost = {
      image = "index.docker.io/ghost:6-alpine";
      pull = "newer";
      podman.user = "ghost";
      volumes = [
        "/var/lib/ghost/content:/var/lib/ghost/content"
      ];
      extraOptions = [ "--userns=keep-id" ];
      environment = {
        url = "https://ayrlin.freopen.org";
        database__client = "sqlite3";
        database__connection__filename = "/var/lib/ghost/content/data/ghost.db";
        database__connection__useNullAsDefault = "true";
        database__connection__debug = "false";
        security__staffDeviceVerification = "false";
      };
      ports = [ "127.0.0.1:2368:2368" ];
    };
  };
  systemd.services.podman-ghost.serviceConfig = {
    RestartSec = 10;
    StartLimitBurst = 3;
    StartLimitIntervalSec = 60 * 60;
  };
  services.nginx.virtualHosts."ayrlin.freopen.org" = {
    forceSSL = true;
    enableACME = true;
    locations."/".proxyPass = "http://127.0.0.1:2368/";
  };
}
