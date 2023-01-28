{ pkgs, config, ... }: {
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
          job_name = "prometheus_scraper";
          static_configs = [{
            targets = [
              "localhost:8888" # opentelemetry-collector
              "localhost:8001" # cloudflared
              # Prometheus exporters:
              "localhost:9100" # node
              "localhost:9558" # systemd
              "localhost:9586" # wireguard
              # My services
              "localhost:4001" # chess-erdos
            ];
          }];
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
        telemetry.logs.level = "debug";
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
  services.prometheus.exporters = {
    node = {
      enable = true;
      enabledCollectors = [ "processes" "systemd" ];
    };
    wireguard.enable = true;
    systemd = {
      enable = true;
      extraFlags = [
        "--systemd.collector.enable-ip-accounting"
        "--systemd.collector.enable-restart-count"
      ];
    };
  };
  services.netdata = {
    enable = true;
    config = { db."storage tiers" = 5; };
  };
}
