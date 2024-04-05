{ config, pkgs, ... }: {
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
      db."storage tiers" = 5;
      ml.enabled = true;
      "plugin:go.d"."command options" = "-d";
      web =
        let certs = config.security.acme.certs."netdata.freopen.org".directory;
        in {
          "bind to" =
            "*=streaming^SSL=force localhost:19998=dashboard^SSL=optional";
          "ssl key" = "${certs}/key.pem";
          "ssl certificate" = "${certs}/fullchain.pem";
        };
    };
    configs = {
      "go.d/prometheus.conf" = {
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
          {
            name = "rclone";
            url = "http://127.0.0.1:5572/metrics";
          }
        ];
      };
      "go.d/systemdunits.conf" = {
        jobs = [{
          name = "all";
          include = [ "*" ];
        }];
      };
      "go.d/nginx.conf" = {
        jobs = [{
          name = "local";
          url = "http://127.0.0.1/nginx_status";
        }];
      };
      "go.d/web_log.conf" = {
        jobs = [{
          name = "nginx";
          path = "/var/log/nginx/access.log";
          parser.log_type = "json";
        }];
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
  users.groups.netdata-cert.members = [ "netdata" "nginx" ];
  security.acme.certs."netdata.freopen.org" = {
    webroot = "/var/lib/acme/acme-challenge";
    group = "netdata-cert";
  };
  services.nginx.virtualHosts."netdata.freopen.org" = {
    forceSSL = true;
    useACMEHost = "netdata.freopen.org";
  };
}
