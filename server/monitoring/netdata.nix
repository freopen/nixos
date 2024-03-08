{ config, lib, pkgs, ... }: {
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
    package = pkgs.netdataCloud;
    claimTokenFile = config.age.secrets.netdata.path;
    config = {
      db."storage tiers" = 5;
      ml.enabled = true;
      web =
        let certs = config.security.acme.certs."netdata.freopen.org".directory;
        in {
          "bind to" = "*=streaming^SSL=force";
          "ssl key" = "${certs}/key.pem";
          "ssl certificate" = "${certs}/fullchain.pem";
        };
    };
    configDir = (builtins.mapAttrs (file: config:
      builtins.toFile (builtins.baseNameOf file)
      (lib.generators.toYAML { } config)) {
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
        "go.d.conf" = {
          enabled = true;
          default_run = true;
          max_procs = 0;
          modules = { systemdunits = true; };
        };
      }) // {
        "stream.conf" = config.age.secrets.netdata_stream_fv0.path;
      };
    enableAnalyticsReporting = true;
  };
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
