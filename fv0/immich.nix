{ pkgs, lib, ... }:
let
  config = {
    logging.level = "warn";
    ffmpeg.transcode = "disabled";
    image = {
      colorspace = "p3";
      previewFormat = "jpeg";
      previewSize = 720;
      quality = 80;
      thumbnailFormat = "webp";
      thumbnailSize = 250;
    };
    job = {
      backgroundTask.concurrency = 5;
      faceDetection.concurrency = 1;
      library.concurrency = 1;
      metadataExtraction.concurrency = 1;
      migration.concurrency = 1;
      search.concurrency = 5;
      sidecar.concurrency = 1;
      smartSearch.concurrency = 1;
      thumbnailGeneration.concurrency = 5;
      videoConversion.concurrency = 1;
    };
    library = {
      scan.enabled = false;
      watch.enabled = false;
    };
    machineLearning = {
      clip = {
        enabled = true;
        modelName = "XLM-Roberta-Large-Vit-B-16Plus";
      };
      enabled = true;
      facialRecognition = {
        enabled = true;
        maxDistance = 0.5;
        minFaces = 3;
        minScore = 0.7;
        modelName = "buffalo_l";
      };
      url = "http://127.0.0.1:5003";
    };
    newVersionCheck.enabled = false;
    server.externalDomain = "https://photos.freopen.org";
    storageTemplate = {
      enabled = true;
      template =
        "{{y}}/{{MM}}-{{dd}}/{{yy}}{{MM}}{{dd}}_{{HH}}{{mm}}{{ss}}_{{filename}}";
    };
    trash = {
      days = 9999999999999;
      enabled = true;
    };
  };
in {
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
    "d /var/lib/immich/library/library 0550 immich immich"
    "d /var/lib/immich/library/thumbs 0550 immich immich"
    "d /var/lib/immich/model-cache 0770 immich immich"
  ];
  systemd.mounts = map (dir: {
    what = "/mnt/rclone/immich/${dir}";
    where = "/var/lib/immich/library/${dir}";
    options = "bind,_netdev";
    bindsTo = [ "rclone.service" ];
    after = [ "rclone.service" ];
    unitConfig = { ConditionPathExists = "/mnt/rclone/immich/${dir}"; };
  }) [ "library" "thumbs" ];
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
    version = "main";
    immich_unit = exec: {
      environment = { PODMAN_SYSTEMD_UNIT = "%n"; };
      postStop = "${podman} rm -f -i --cidfile=/run/immich/%N/%N.cid";
      path = [ "/run/wrappers" ];
      bindsTo = [
        "immich.target"
        "redis-immich.service"
        "postgresql.service"
        "var-lib-immich-library-thumbs.mount"
        "var-lib-immich-library-library.mount"
      ];
      after = [
        "redis-immich.service"
        "postgresql.service"
        "var-lib-immich-library-thumbs.mount"
        "var-lib-immich-library-library.mount"
      ];
      unitConfig = {
        RequiresMountsFor =
          "/var/lib/immich/library/library /var/lib/immich/library/thumbs";
      };
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
                "${
                  builtins.toFile "immich-config.json" (builtins.toJSON config)
                }:/immich-config.json"
              ];
              env = [
                "DB_URL=socket://immich:@/run/postgresql?db=immich"
                "REDIS_SOCKET=/run/redis-immich/redis.sock"
                "PORT=5000"
                "SERVER_PORT=5001"
                "MICROSERVICES_PORT=5002"
                "MACHINE_LEARNING_PORT=5003"
                "IMMICH_CONFIG_FILE=/immich-config.json"
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
        Restart = "on-failure";
      };
    };
  in {
    immich-server =
      immich_unit "ghcr.io/immich-app/immich-server:${version} start.sh immich";
    immich-microservices = immich_unit
      "ghcr.io/immich-app/immich-server:${version} start.sh microservices";
    immich-machine-learning =
      immich_unit "ghcr.io/immich-app/immich-machine-learning:${version}";
  };
  systemd.targets.immich = {
    after = [
      "immich-server.service"
      "immich-microservices.service"
      "immich-machine-learning.service"
    ];
    bindsTo = [
      "immich-server.service"
      "immich-microservices.service"
      "immich-machine-learning.service"
    ];
    wantedBy = [ "multi-user.target" ];
  };
}
