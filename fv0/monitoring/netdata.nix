{ config, pkgs, ... }:
{
  age.secrets.netdata = {
    file = ../../secrets/netdata.age;
    owner = "netdata";
    group = "netdata";
  };
  age.secrets.netdata_stream_fv0 = {
    file = ../../secrets/netdata_stream_fv0.age;
    owner = "netdata";
    group = "netdata";
  };
  networking.firewall.allowedTCPPorts = [ 19999 ];
  services.netdata = {
    enable = true;
    package = pkgs.unstable.netdataCloud;
    claimTokenFile = config.age.secrets.netdata.path;
    config = {
      global = {
        "process scheduling policy" = "keep";
      };
      db = {
        mode = "dbengine";
        "storage tiers" = 4;
        "dbengine multihost disk space MB" = 256;
        "dbengine tier 1 multihost disk space MB" = 256;
        "dbengine tier 2 multihost disk space MB" = 256;
        "dbengine tier 3 multihost disk space MB" = 256;
        "dbengine tier 1 update every iterations" = 60;
        "dbengine tier 2 update every iterations" = 60;
        "dbengine tier 3 update every iterations" = 12;
      };
      ml.enabled = true;
      web =
        let
          certs = config.security.acme.certs."netdata.freopen.org".directory;
        in
        {
          "bind to" = "*=streaming^SSL=force localhost:19998=dashboard^SSL=optional";
          "ssl key" = "${certs}/key.pem";
          "ssl certificate" = "${certs}/fullchain.pem";
        };
      plugins = {
        "netdata monitoring" = true;
        "netdata monitoring extended" = true;
      };
    };
    configs = {
      "go.d/prometheus.conf" = {
        autodetection_retry = 60;
        jobs = [
          {
            name = "wireguard_local";
            url = "http://127.0.0.1:9586/metrics";
          }
          {
            name = "grafana-alloy";
            url = "http://127.0.0.1:12345/metrics";
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
          {
            name = "immich-server";
            url = "http://127.0.0.1:5004/metrics";
          }
          {
            name = "immich-microservices";
            url = "http://127.0.0.1:5005/metrics";
          }
        ];
      };
      "go.d/systemdunits.conf" = {
        jobs = [
          {
            name = "all";
            include = [ "*" ];
          }
        ];
      };
      "go.d/nginx.conf" = {
        jobs = [
          {
            name = "local";
            url = "http://127.0.0.1/nginx_status";
          }
        ];
      };
      "go.d/web_log.conf" = {
        jobs = [
          {
            name = "nginx";
            path = "/var/log/nginx/access.log";
            parser.log_type = "json";
          }
        ];
      };
      "go.d.conf" = {
        enabled = true;
        default_run = true;
        max_procs = 0;
        modules = {
          systemdunits = true;
          web_log = true;
        };
      };
      "stream.conf" = config.age.secrets.netdata_stream_fv0.path;
    };
    enableAnalyticsReporting = true;
  };
  users.users.netdata.extraGroups = [ "nginx" ];
  users.groups.netdata-cert.members = [
    "netdata"
    "nginx"
  ];
  security.acme.certs."netdata.freopen.org" = {
    webroot = "/var/lib/acme/acme-challenge";
    group = "netdata-cert";
  };
  services.nginx.virtualHosts."netdata.freopen.org" = {
    forceSSL = true;
    useACMEHost = "netdata.freopen.org";
  };
  services.prometheus.exporters = {
    wireguard.enable = true;
  };
}
