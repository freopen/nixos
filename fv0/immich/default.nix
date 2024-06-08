{ pkgs, lib, ... }:
let
  immichConfig = builtins.toFile "immich-config.json" (builtins.toJSON {
    logging.level = "warn";
    storageTemplate = {
      enabled = true;
      template =
        "{{y}}/{{MM}}-{{dd}}/{{yy}}{{MM}}{{dd}}_{{HH}}{{mm}}{{ss}}_{{filename}}";
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
    image = {
      colorspace = "p3";
      previewFormat = "jpeg";
      previewSize = 720;
      quality = 80;
      thumbnailFormat = "webp";
      thumbnailSize = 250;
    };
    ffmpeg.transcode = "disabled";
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
    library = {
      scan.enabled = false;
      watch.enabled = false;
    };
    trash = {
      days = 9999999999999;
      enabled = true;
    };
    server.externalDomain = "https://photos.freopen.org";
    newVersionCheck.enabled = false;
  });
in {
  imports = [ ./rclone.nix ];
  users = {
    users = {
      immich = {
        group = "immich";
        extraGroups = [ "rclone" "redis-immich" ];
        isSystemUser = true;
        linger = true;
        home = "/var/lib/immich";
        autoSubUidGidRange = true;
      };
    };
    groups = { immich = { }; };
  };
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
  systemd.tmpfiles.rules = [
    "d /var/lib/immich 0770 immich immich"
    "d /var/lib/immich/upload 0770 immich immich"
    "d /var/lib/immich/model-cache 0770 immich immich"
  ];
  virtualisation.podman.enable = true;
  systemd.services = let
    podman = "${pkgs.podman}/bin/podman";
    version = "v1.105.1";
    immich_unit =
      { container ? "immich-server", exec ? "", metricsPort ? 0, }: {
        environment = { PODMAN_SYSTEMD_UNIT = "%n"; };
        postStop = "${podman} rm -f -i --cidfile=/run/immich/%N/%N.cid";
        path = [ "/run/wrappers" ];
        bindsTo = [
          "immich.target"
          "redis-immich.service"
          "postgresql.service"
          "immich-rclone.service"
        ];
        after = [
          "redis-immich.service"
          "postgresql.service"
          "immich-rclone.service"
        ];
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
                  "/var/lib/immich/upload:/usr/src/app/upload"
                  "/var/lib/immich/cloud/library:/usr/src/app/upload/library"
                  "/var/lib/immich/cloud/thumbs:/usr/src/app/upload/thumbs"
                  "/var/lib/immich/model-cache:/cache"
                  "/run/postgresql:/run/postgresql"
                  "/run/redis-immich:/run/redis-immich"
                  "${immichConfig}:/immich-config.json"
                ];
                env = [
                  "IMMICH_CONFIG_FILE=/immich-config.json"
                  "DB_URL=socket://immich:@/run/postgresql?db=immich"
                  "REDIS_SOCKET=/run/redis-immich/redis.sock"
                  "SERVER_PORT=5001"
                  "MICROSERVICES_PORT=5002"
                  "MACHINE_LEARNING_PORT=5003"
                  "IMMICH_METRICS=true"
                  "IMMICH_METRICS_PORT=${builtins.toString metricsPort}"
                ];
              }
            } ghcr.io/immich-app/${container}:${version} ${exec}";
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
    immich-server = immich_unit {
      exec = "start.sh immich";
      metricsPort = 5004;
    };
    immich-microservices = immich_unit {
      exec = "start.sh microservices";
      metricsPort = 5005;
    };
    immich-machine-learning =
      immich_unit { container = "immich-machine-learning"; };
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
