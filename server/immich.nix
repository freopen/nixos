{ pkgs, lib, ... }:
let
  uid = 15015;
  gid = 15015;
in {
  virtualisation.podman = { enable = true; };
  users = {
    users.immich = {
      inherit uid;
      isNormalUser = true;
      linger = true;
      group = "immich";
      extraGroups = [ "rclone" "redis-immich" ];
    };
    groups.immich = { inherit gid; };
  };
  systemd.tmpfiles.rules = [
    "d /var/lib/immich 0770 immich immich"
    "d /var/lib/immich/library 0770 immich immich"
  ];
  systemd.mounts = [{
    what = "/mnt/rclone/immich";
    where = "/var/lib/immich/library";
    options = "bind";
    bindsTo = [ "rclone.service" ];
    after = [ "rclone.service" ];
  }];
  services = {
    redis.servers.immich = { enable = true; };
    postgresql = {
      ensureUsers = [{
        name = "immich";
        ensureDBOwnership = true;
      }];
      ensureDatabases = [ "immich" ];
    };
    nginx.virtualHosts."photos.freopen.org" = {
      forceSSL = true;
      enableACME = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:3001/";
        proxyWebsockets = true;
        extraConfig = ''
          client_max_body_size 10000M;
          proxy_buffering off;
        '';
      };
    };
  };
  environment.etc = let
    toINI = lib.generators.toINI { listsAsDuplicateKeys = true; };
    version = "v1.94.1";
  in {
    "containers/systemd/users/${toString uid}/immich-server.container".text =
      toINI {
        Container = {
          Image = "ghcr.io/immich-app/immich-server:${version}";
          Exec = "start.sh immich";
          Network = "host";
          Environment = [
            "DB_URL=socket://immich:@/run/postgresql?db=immich"
            "REDIS_SOCKET=/run/redis-immich/redis.sock"
          ];
          Volume = [
            "/var/lib/immich/library:/usr/src/app/upload"
            "/run/postgresql:/run/postgresql"
            "/run/redis-immich:/run/redis-immich"
          ];
        };
        Service = {
          User = "immich";
          TimeoutStartSec = 900;
          RuntimeDirectory = "immich";
        };
      };
  };
}
