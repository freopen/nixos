{ config, lib, pkgs, ... }: {
  age.secrets.netdata = {
    file = ../../secrets/netdata.age;
    owner = "netdata";
    group = "netdata";
  };
  services.netdata = {
    enable = true;
    package = pkgs.netdataCloud;
    claimTokenFile = config.age.secrets.netdata.path;
    config = {
      db."storage tiers" = 5;
      ml.enabled = true;
    };
    configDir = (builtins.mapAttrs (file: config:
      builtins.toFile (builtins.baseNameOf file)
      (lib.generators.toYAML { } config)) {
        "go.d/prometheus.conf" = {
          jobs = [
            {
              name = "wireguard_local";
              url = "http://127.0.0.1:9586/metrics";
            }
            {
              name = "opentelemetry";
              url = "http://127.0.0.1:8888/metrics";
            }
            {
              name = "cloudflared";
              url = "http://127.0.0.1:8001/metrics";
            }
            {
              name = "chess_erdos";
              url = "http://127.0.0.1:4001/metrics";
            }
            {
              name = "rclone";
              url = "http://127.0.0.1:5572/metrics";
            }
          ];
        };
        "go.d/systemdunits.conf" = {
          jobs = [{
            name = "all";
            include = [ "*" ];
          }];
        };
        "go.d/nginx.conf" = {
          jobs = [{
            name = "local";
            url = "http://127.0.0.1/nginx_status";
          }];
        };
        "go.d.conf" = {
          enabled = true;
          default_run = true;
          max_procs = 0;
          modules = { systemdunits = true; };
        };
      }) // (builtins.mapAttrs (file: config:
        builtins.toFile (builtins.baseNameOf file)
        (lib.generators.toINI { } config)) {
          "stream.conf" = {
            "fc4f3cb4-a7ac-4c86-8ff8-308cb3310d83".enabled = true;
          };
        });
    enableAnalyticsReporting = true;
  };
}
