{ pkgs, config, ... }:
{
  age.secrets.newrelic.file = ../secrets/newrelic.age;
  services.prometheus = {
    enable = true;
    exporters.node.enable = true;
    remoteWrite = [{
      url = "https://metric-api.eu.newrelic.com/prometheus/v1/write?prometheus_server=server";
      bearer_token_file = config.age.secrets.newrelic.path;
    }];
  };
}
