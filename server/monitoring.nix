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
                "localhost:9100" # prometheus-node-exporter
              ];
            }];
          }];
          journald = {
            units = [ "*" ];
          };
        };
        processors.transform = {
          logs.queries = [
            "set(attributes, body)"
          ];

        };
        service = {
          telemetry.metrics.level = "detailed";
          telemetry.logs.level = "debug";
          pipelines = {
            metrics = {
              receivers = [ "prometheus" ];
              processors = [];
              exporters = [ "otlp" ];
            };
            logs = {
              receivers = [ "journald" ];
              processors = [ "transform" ];
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
  services.prometheus.exporters.node = {
    enable = true;
  };
}
