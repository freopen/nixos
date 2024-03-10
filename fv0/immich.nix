{ pkgs, lib, ... }: {
  virtualisation.podman = { enable = true; };
  users = {
    users.immich = {
      group = "immich";
      extraGroups = [ "rclone" "redis-immich" ];
      isSystemUser = true;
      linger = true;
      home = "/var/lib/immich";
      autoSubUidGidRange = true;
    };
    groups.immich = { };
  };
  systemd.tmpfiles.rules = [
    "d /var/lib/immich 0770 immich immich"
    "d /var/lib/immich/library 0770 immich immich"
    "d /var/lib/immich/model-cache 0770 immich immich"
  ];
  systemd.mounts = [{
    what = "/mnt/rclone/immich";
    where = "/var/lib/immich/library";
    options = "bind";
    bindsTo = [ "rclone.service" ];
    after = [ "rclone.service" ];
  }];
  services = {
    redis.servers.immich = {
      enable = true;
      user = "immich";
    };
    postgresql = {
      ensureUsers = [{
        name = "immich";
        ensureDBOwnership = true;
      }];
      ensureDatabases = [ "immich" ];
    };
    nginx.virtualHosts."photos.freopen.org" = {
      forceSSL = true;
      useACMEHost = "freopen.org";
      locations."/" = {
        proxyPass = "http://127.0.0.1:5001/";
        proxyWebsockets = true;
        extraConfig = ''
          client_max_body_size 10000M;
          proxy_buffering off;
        '';
      };
    };
  };
  systemd.services = let
    podman = "${pkgs.podman}/bin/podman";
    version = "1.98.1";
    immich_unit = exec: {
      environment = { PODMAN_SYSTEMD_UNIT = "%n"; };
      postStop = "${podman} rm -f -i --cidfile=/run/immich/%N/%N.cid";
      path = [ "/run/wrappers" ];
      requires = [ "redis-immich.service" "postgresql.service" ];
      after = [ "redis-immich.service" "postgresql.service" ];
      unitConfig = { RequiresMountsFor = "/var/lib/immich/library"; };
      serviceConfig = {
        ExecStart = "${podman} run ${
            lib.cli.toGNUCommandLineShell { } {
              name = "%N";
              cidfile = "/run/immich/%N/%N.cid";
              replace = true;
              rm = true;
              cgroupns = "host";
              cgroups = "disabled";
              network = "host";
              userns = "keep-id";
              detach = true;
              sdnotify = "conmon";
              volume = [
                "/var/lib/immich/library:/usr/src/app/upload"
                "/var/lib/immich/model-cache:/cache"
                "/run/postgresql:/run/postgresql"
                "/run/redis-immich:/run/redis-immich"
              ];
              env = [
                "DB_URL=socket://immich:@/run/postgresql?db=immich"
                "REDIS_SOCKET=/run/redis-immich/redis.sock"
                "PORT=5000"
                "SERVER_PORT=5001"
                "MICROSERVICES_PORT=5002"
                "MACHINE_LEARNING_PORT=5003"
              ];
            }
          } ${exec}";
        Type = "notify";
        NotifyAccess = "all";
        User = "immich";
        RuntimeDirectory = "immich/%N";
        TimeoutStartSec = 900;
        Delegate = true;
        SyslogIdentifier = "%N";
      };
    };
  in {
    immich-server = immich_unit
      "ghcr.io/immich-app/immich-server:v${version} start.sh immich";
    immich-microservices = immich_unit
      "ghcr.io/immich-app/immich-server:v${version} start.sh microservices";
    immich-machine-learning =
      immich_unit "ghcr.io/immich-app/immich-machine-learning:v${version}";
  };
  systemd.targets.immich = {
    requires = [
      "immich-server.service"
      "immich-microservices.service"
      "immich-machine-learning.service"
    ];
    wantedBy = [ "multi-user.target" ];
  };
}
