{ pkgs, config, ... }:
{
  age.secrets.newrelic = {
    file = ../secrets/newrelic.age;
    owner = "prometheus";
    group = "prometheus";
  };
  services.prometheus = {
    enable = true;
    scrapeConfigs = [
      {
        job_name = "node";
        static_configs = [{
          targets = ["localhost:9100"];
        }];
      }
    ];
    exporters.node.enable = true;
    remoteWrite = [{
      url = "https://metric-api.eu.newrelic.com/prometheus/v1/write?prometheus_server=server";
      bearer_token_file = config.age.secrets.newrelic.path;
    }];
  };
}
