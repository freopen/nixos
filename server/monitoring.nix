{ pkgs, config, ... }:
{
  age.secrets.newrelic = {
    file = ../secrets/newrelic.age;
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
  systemd.services.opentelemetry-collector =
    let
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
          journald = {
            units = [ "*" ];
          };
          otlp.protocols.grpc.endpoint = "localhost:4317";
        };
        processors = {
          batch = {
            timeout = "10s";
          };
          transform = {
            logs.statements = [
              "set(attributes, body)"
            ];
          };
        };
        service = {
          telemetry.metrics.level = "detailed";
          telemetry.logs.level = "debug";
          pipelines = {
            metrics = {
              receivers = [ "prometheus" ];
              processors = [ "batch" ];
              exporters = [ "otlp" ];
            };
            logs = {
              receivers = [ "journald" ];
              processors = [ "transform" "batch" ];
              exporters = [ "otlp" ];
            };
            traces = {
              receivers = [ "otlp" ];
              processors = [ "batch" ];
              exporters = [ "otlp" ];
            };
          };
        };
      };
    in
    {
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      restartTriggers = [ pkgs.opentelemetry-collector-contrib otel_config ];
      serviceConfig = {
        User = "opentelemetry";
        ExecStart =
          "${pkgs.opentelemetry-collector-contrib}/bin/otelcontribcol" +
          " --config=" + builtins.toFile "config.yaml" otel_config +
          " --config=" + config.age.secrets.newrelic.path;
        Restart = "always";
      };
    };
  services.prometheus.exporters = {
    node = {
      enable = true;
      enabledCollectors = [
        "processes"
        "systemd"
      ];
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
}
