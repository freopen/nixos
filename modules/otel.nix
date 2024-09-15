{ config, pkgs, ... }:
{
  environment.persistence."/nix/persist".directories = [ "/var/lib/private/opentelemetry-collector" ];
  services.opentelemetry-collector = {
    enable = true;
    package = pkgs.unstable.opentelemetry-collector-contrib;
    settings = {
      receivers = {
        hostmetrics = {
          collection_interval = "10s";
          scrapers = {
            cpu = { };
            load = { };
            memory = { };
            disk = { };
            network = { };
            paging = { };
            processes = { };
          };
        };
        otlp.protocols.grpc.endpoint = "localhost:4317";
        journald.units = [ "*" ];
      };
      processors = {
        batch.timeout = "300s";
        memory_limiter = {
          check_interval = "1s";
          limit_mib = 100;
        };
      };
      exporters = {
        clickhouse = {
          endpoint = "https://clickhouse.freopen.org";
          username = "otel_collector";
          password = "\${env:CLICKHOUSE_PASSWORD}";
          database = "otel";
          create_schema = false;
        };
      };
      extensions = {
        memory_ballast.size_mib = 50;
      };
      service = {
        telemetry.metrics.level = "detailed";
        telemetry.logs.level = "info";
        extensions = [ "memory_ballast" ];
        pipelines = {
          metrics = {
            receivers = [
              "hostmetrics"
              "otlp"
            ];
            processors = [
              "memory_limiter"
              "batch"
            ];
            exporters = [ "clickhouse" ];
          };
        };
      };
    };
  };
  age.secrets.otel_collector.file = ../secrets/otel_collector.age;
  systemd.services.opentelemetry-collector.serviceConfig.EnvironmentFile =
    config.age.secrets.otel_collector.path;
}
