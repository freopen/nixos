{ lib, config, ... }:
{
  services.clickhouse.enable = true;
  age.secrets.clickhouse.file = ../secrets/clickhouse.age;
  systemd.services.clickhouse = {
    restartTriggers = [
      config.environment.etc."clickhouse-server/config.d/config.yaml".text
      config.environment.etc."clickhouse-server/users.d/users.yaml".text
      config.age.secrets.clickhouse.file
    ];
    serviceConfig.EnvironmentFile = config.age.secrets.clickhouse.path;
  };
  environment.etc."clickhouse-server/config.d/config.yaml".text = lib.generators.toYAML { } {
    logger = {
      "@replace" = "replace";
      level = "debug";
      use_syslog = true;
    };
  };
  environment.etc."clickhouse-server/users.d/users.yaml".text = lib.generators.toYAML { } {
    users = {
      default = {
        password."@remove" = "remove";
        password_sha256_hex."@from_env" = "DEFAULT_PASSWORD";
      };
      otel_collector = {
        password_sha256_hex."@from_env" = "OTEL_COLLECTOR_PASSWORD";
        grants.query = "GRANT INSERT ON otel.*";
      };
      grafana = {
        password_sha256_hex."@from_env" = "GRAFANA_PASSWORD";
        grants.query = "GRANT SELECT ON *.*";
      };
    };
  };
  services.nginx.virtualHosts."clickhouse.freopen.org" = {
    forceSSL = true;
    enableACME = true;
    locations."/".proxyPass = "http://127.0.0.1:8123/";
  };
  environment.persistence."/nix/persist".directories = [ "/var/lib/clickhouse" ];
  systemd.tmpfiles.rules = [ "d /var/lib/clickhouse 0750 clickhouse clickhouse" ];
}
