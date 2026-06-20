{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.services.grafana-alloy-freopen;
  quote = builtins.toJSON;
  sanitizeLabel = lib.replaceStrings [ "-" "." "/" ":" ] [ "_" "_" "_" "_" ];
  section = name: body: ''
    // ${name}
    ${body}
  '';
  sharedConfig = section "Shared secret material" ''
    local.file "grafana_key" {
      filename = "/run/agenix/grafana"
      is_secret = true
    }
  '';
  logsPipeline = section "Logs: journald -> relabel -> Grafana Loki" ''
    loki.write "grafana" {
      endpoint {
        url = "https://logs-prod-eu-west-0.grafana.net/loki/api/v1/push"

        basic_auth {
          username = "336555"
          password = local.file.grafana_key.content
        }
      }
    }

    loki.relabel "journald" {
      forward_to = [loki.write.grafana.receiver]

      rule {
        source_labels = ["__journal__systemd_unit"]
        target_label = "unit"
      }

      rule {
        source_labels = ["__journal_priority_keyword"]
        target_label = "level"
      }

      rule {
        source_labels = ["__journal__hostname"]
        target_label = "host"
      }
    }

    loki.source.journal "journald" {
      forward_to = [loki.relabel.journald.receiver]
      format_as_json = true
    }
  '';
  tracesPipeline = section "Traces: OTLP receiver -> batch -> Grafana Tempo" ''
    tracing {
      write_to = [otelcol.processor.batch.default.input]
    }

    otelcol.exporter.otlp "default" {
      client {
        endpoint = "tempo-eu-west-0.grafana.net:443"
        auth = otelcol.auth.basic.grafana.handler
      }
    }

    otelcol.processor.batch "default" {
      output {
        traces = [otelcol.exporter.otlp.default.input]
      }
    }

    otelcol.receiver.otlp "default" {
      grpc {
        endpoint = "127.0.0.1:4317"
      }

      output {
        traces = [otelcol.processor.batch.default.input]
      }
    }

    otelcol.auth.basic "grafana" {
      username = "333068"
      password = local.file.grafana_key.content
    }
  '';
  renderMetricScrape =
    {
      name,
      targets,
      jobName ? null,
    }:
    if jobName == null then
      ''
        prometheus.scrape ${quote (sanitizeLabel name)} {
          targets = ${targets}
          forward_to = [prometheus.remote_write.grafana.receiver]
        }
      ''
    else
      ''
        prometheus.scrape ${quote (sanitizeLabel name)} {
          targets = ${targets}
          job_name = ${quote jobName}
          forward_to = [prometheus.remote_write.grafana.receiver]
        }
      '';
  renderPortScrape = name: port: ''
    prometheus.scrape ${quote (sanitizeLabel name)} {
      targets = [
        {
          "__address__" = ${quote "127.0.0.1:${toString port}"},
          "instance" = ${quote config.networking.hostName},
        },
      ]
      job_name = ${quote name}
      forward_to = [prometheus.remote_write.grafana.receiver]
    }
  '';
  metricsDestination = section "Metrics destination: Grafana Cloud Prometheus" ''
    prometheus.remote_write "grafana" {
      external_labels = {
        "host" = ${quote config.networking.hostName},
      }

      endpoint {
        url = "https://prometheus-prod-01-eu-west-0.grafana.net/api/prom/push"

        basic_auth {
          username = "675169"
          password = local.file.grafana_key.content
        }
      }
    }
  '';
  hostMetrics = section "Metrics source: host and systemd units" (
    ''
      prometheus.exporter.unix "default" {
        include_exporter_metrics = true
        enable_collectors = [ "systemd" ]

        systemd {
          unit_include = ".+"
        }
      }
    ''
    + renderMetricScrape {
      name = "unix";
      targets = "prometheus.exporter.unix.default.targets";
    }
  );
  alloyMetrics = section "Metrics source: Alloy itself" (
    ''
      prometheus.exporter.self "default" {
      }
    ''
    + renderMetricScrape {
      name = "alloy";
      targets = "prometheus.exporter.self.default.targets";
    }
  );
  serviceMetrics = section "Metrics source: registered local services" (
    lib.concatMapStrings (name: renderPortScrape name cfg.metrics.${name}) (lib.attrNames cfg.metrics)
  );
  alloyConfigText = ''
    ${sharedConfig}
    ${logsPipeline}
    ${tracesPipeline}
    ${metricsDestination}
    ${hostMetrics}
    ${alloyMetrics}
    ${serviceMetrics}
  '';
  alloyConfig = pkgs.writeText "config.alloy" alloyConfigText;
in
{
  options = {
    services.grafana-alloy-freopen = {
      enable = lib.mkEnableOption "";
      metrics = lib.mkOption {
        type = lib.types.attrsOf lib.types.port;
        default = { };
      };
      configFile = lib.mkOption {
        type = lib.types.path;
        internal = true;
        readOnly = true;
      };
    };
  };
  config = lib.mkIf cfg.enable {
    services.grafana-alloy-freopen.configFile = alloyConfig;
    users.users.grafana-alloy = {
      isSystemUser = true;
      group = "grafana-alloy";
      extraGroups = [ "systemd-journal" ];
    };
    users.groups.grafana-alloy = { };
    age.secrets.grafana = {
      file = ../secrets/grafana.age;
      owner = "grafana-alloy";
    };
    systemd.services.grafana-alloy = {
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        User = "grafana-alloy";
        ExecStart = ''
          ${pkgs.unstable.grafana-alloy}/bin/alloy \
            run ${cfg.configFile} \
            --storage.path /var/lib/grafana-alloy
        '';
        Restart = "always";
        StateDirectory = "grafana-alloy";
      };
    };
  };
}
