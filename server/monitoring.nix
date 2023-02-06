{ pkgs, lib, config, ... }: {
  age.secrets.telemetry = {
    file = ../secrets/telemetry.age;
    owner = "opentelemetry";
    group = "opentelemetry";
  };
  users.users.opentelemetry = {
    isSystemUser = true;
    group = "opentelemetry";
    extraGroups = [ "systemd-journal" ];
    packages = with pkgs; [ opentelemetry-collector-contrib ];
  };
  users.groups.opentelemetry = { };
  systemd.services.opentelemetry-collector = let
    otel_config = builtins.toJSON {
      receivers = {
        prometheus.config.scrape_configs = [{
          job_name = "netdata";
          honor_labels = true;
          metrics_path = "/api/v1/allmetrics";
          params = { format = [ "prometheus" ]; };
          static_configs = [{ targets = [ "localhost:19999" ]; }];
        }];
        otlp.protocols.grpc.endpoint = "localhost:4317";
        journald = { units = [ "*" ]; };
      };
      processors = {
        batch = { timeout = "10s"; };
        memory_limiter = {
          check_interval = "1s";
          limit_mib = 100;
        };
      };
      extensions = { memory_ballast = { size_mib = 50; }; };
      exporters = {
        prometheusremotewrite = {
          endpoint =
            "https://prometheus-prod-01-eu-west-0.grafana.net/api/prom/push";
          auth.authenticator = "basicauth/metrics";
        };
        "otlp/traces" = {
          endpoint = "tempo-eu-west-0.grafana.net:443";
          auth.authenticator = "basicauth/traces";
        };
        loki = {
          endpoint = "https://logs-prod-eu-west-0.grafana.net/loki/api/v1/push";
          auth.authenticator = "basicauth/logs";
        };
      };
      service = {
        telemetry.metrics.level = "detailed";
        telemetry.logs.level = "info";
        extensions = [
          "basicauth/metrics"
          "basicauth/traces"
          "basicauth/logs"
          "memory_ballast"
        ];
        pipelines = {
          metrics = {
            receivers = [ "prometheus" ];
            processors = [ "memory_limiter" "batch" ];
            exporters = [ "prometheusremotewrite" ];
          };
          traces = {
            receivers = [ "otlp" ];
            processors = [ "memory_limiter" "batch" ];
            exporters = [ "otlp/traces" ];
          };
          logs = {
            receivers = [ "journald" ];
            processors = [ "memory_limiter" "batch" ];
            exporters = [ "loki" ];
          };
        };
      };
    };
  in {
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    restartTriggers = [ pkgs.opentelemetry-collector-contrib otel_config ];
    serviceConfig = {
      User = "opentelemetry";
      ExecStart = "${pkgs.opentelemetry-collector-contrib}/bin/otelcontribcol"
        + " --config=" + builtins.toFile "config.yaml" otel_config
        + " --config=" + config.age.secrets.telemetry.path;
      Restart = "always";
    };
  };
  services.prometheus.exporters = { wireguard.enable = true; };
  services.netdata = {
    enable = true;
    config = { db."storage tiers" = 5; };
    configDir = {
      "go.d/prometheus.conf" = builtins.toFile "prometheus.conf"
        (lib.generators.toYAML { } {
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
          ];
        });
      "go.d/systemdunits.conf" = builtins.toFile "systemdunits.conf"
        (lib.generators.toYAML { } {
          jobs = [{
            name = "all";
            include = [ "*" ];
          }];
        });
      "go.d.conf" = builtins.toFile "go.d.conf" (lib.generators.toYAML { } {
        enabled = true;
        default_run = true;
        max_procs = 0;
        modules = { systemdunits = true; };
      });
    };
  };
}
