{ pkgs, lib, ... }:
let
  immichConfig = builtins.toFile "immich-config.json" (
    builtins.toJSON {
      logging.level = "warn";
      storageTemplate = {
        enabled = true;
        template = "{{y}}/{{MM}}-{{dd}}/{{yy}}{{MM}}{{dd}}_{{HH}}{{mm}}{{ss}}_{{filename}}";
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
        preview = {
          format = "jpeg";
          size = 720;
          quality = 80;
        };
        thumbnail = {
          format = "webp";
          size = 250;
          quality = 80;
        };
      };
      ffmpeg.transcode = "disabled";
      machineLearning = {
        enabled = true;
        clip = {
          enabled = true;
          modelName = "XLM-Roberta-Large-Vit-B-16Plus";
        };
        facialRecognition = {
          enabled = true;
          maxDistance = 0.5;
          minFaces = 3;
          minScore = 0.7;
          modelName = "buffalo_l";
        };
        urls = [ "http://127.0.0.1:5003" ];
      };
      library = {
        scan.enabled = false;
        watch.enabled = false;
      };
      trash = {
        enabled = true;
        days = 9999999999999;
      };
      server.externalDomain = "https://photos.freopen.org";
      newVersionCheck.enabled = false;
    }
  );
in
{
  imports = [ ./rclone.nix ];
  users = {
    users = {
      immich = {
        group = "immich";
        extraGroups = [
          "rclone"
          "redis-immich"
        ];
        isSystemUser = true;
        linger = true;
        home = "/var/lib/immich";
        autoSubUidGidRange = true;
      };
    };
    groups = {
      immich = { };
    };
  };
  services = {
    redis.servers.immich = {
      enable = true;
      user = "immich";
    };
    postgresql = {
      ensureUsers = [
        {
          name = "immich";
          ensureDBOwnership = true;
        }
      ];
      ensureDatabases = [ "immich" ];
    };
    nginx.virtualHosts."photos.freopen.org" = {
      forceSSL = true;
      enableACME = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:5001/";
        proxyWebsockets = true;
        extraConfig = ''
          client_max_body_size 50000M;
          proxy_read_timeout 600s;
          proxy_send_timeout 600s;
          send_timeout 600s;
        '';
      };
    };
  };
  systemd.tmpfiles.rules = [
    "d /var/lib/immich 0770 immich immich"
    "d /var/lib/immich/cloud 0770 immich immich"
    "d /var/lib/immich/upload 0770 immich immich"
    "d /var/lib/immich/model-cache 0770 immich immich"
  ];
  environment.persistence."/nix/persist".directories = [
    "/var/lib/immich"
    "/var/lib/redis-immich"
  ];
  virtualisation.podman.enable = true;
  systemd.services =
    let
      podman = "${pkgs.podman}/bin/podman";
      immich_unit =
        { container, port }:
        {
          environment = {
            PODMAN_SYSTEMD_UNIT = "%n";
          };
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
                rmi = true;
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
                  "IMMICH_HOST=127.0.0.1"
                  "IMMICH_PORT=${builtins.toString port}"
                  "IMMICH_TELEMETRY_INCLUDE=all"
                  "IMMICH_API_METRICS_PORT=5004"
                  "IMMICH_MICROSERVICES_METRICS_PORT=5005"
                ];
              }
            } docker-archive:${container}";
            Type = "notify";
            NotifyAccess = "all";
            User = "immich";
            RuntimeDirectory = "immich/%N";
            StateDirectory = "immich";
            TimeoutStartSec = 900;
            Delegate = true;
            SyslogIdentifier = "%N";
            Restart = "on-failure";
          };
        };
    in
    {
      immich-server = immich_unit {
        container = pkgs.dockerTools.pullImage {
          imageName = "ghcr.io/immich-app/immich-server";
          imageDigest = "sha256:06bc7715fa4c4a1641bd0b566c949cd7327f420632b480389fd4d1e70665d046";
          hash = "sha256-ieXjtlmxIWojjuvHgLPpZ8cc/dDd6WkKPmB5u4AwXvg=";
          finalImageName = "ghcr.io/immich-app/immich-server";
          finalImageTag = "v1.142.1";
        };
        port = 5001;
      };
      immich-machine-learning = immich_unit {
        container = pkgs.dockerTools.pullImage {
          imageName = "ghcr.io/immich-app/immich-machine-learning";
          imageDigest = "sha256:9855f6a0a998db508ca97894997b17f3a0a61e9388b204d861110c19c42814eb";
          hash = "sha256-6INEsn30aYfaQY/FGQC5Cyue+3jGc7yMa8WF2U75IoM=";
          finalImageName = "ghcr.io/immich-app/immich-machine-learning";
          finalImageTag = "v1.142.1";
        };
        port = 5003;
      };
    };
  systemd.targets.immich = {
    after = [
      "immich-server.service"
      "immich-machine-learning.service"
    ];
    bindsTo = [
      "immich-server.service"
      "immich-machine-learning.service"
    ];
    wantedBy = [ "multi-user.target" ];
  };
  networking.nftables.preCheckRuleset = ''
    sed 's/skuid immich-rclone/skuid nobody/g' -i ruleset.conf
  '';
  networking.nftables.tables.ratelimit = {
    name = "ratelimit";
    family = "inet";
    content = ''
      limit lim_gcp {
        rate over 1000 kbytes/second burst 1024 mbytes
      }
      chain immich {
        type filter hook input priority filter; policy accept;
        meta skuid immich-rclone ct direction reply limit name "lim_gcp" log drop
      }
    '';
  };
  services.netdata.metrics = {
    immich_server = 5004;
    immich_microservices = 5005;
  };
}
