{ ... }:
let
  logFields = [
    "remote_addr"
    "http_x_forwarded_for"
    "http_cf_ipcountry"
    "request_method"
    "host"
    "request_uri"
    "server_protocol"
    "status"
    "request_length"
    "http_referer"
    "http_user_agent"
    "bytes_sent"
    "request_time"
    "upstream_response_time"
    "ssl_protocol"
    "ssl_cipher"
  ];
  jsonFields = builtins.concatStringsSep "," (map (field: ''"${field}":"''$${field}"'') logFields);
in
{
  networking.firewall.allowedTCPPorts = [
    80
    443
  ];
  services.nginx = {
    enable = true;
    enableReload = true;
    defaultListen = [
      {
        addr = "*";
        port = 80;
        ssl = false;
      }
      {
        addr = "[::]";
        port = 443;
        ssl = true;
      }
      {
        addr = "127.0.0.1";
        port = 8443;
        proxyProtocol = true;
        ssl = true;
      }
    ];
    recommendedTlsSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedGzipSettings = true;
    recommendedBrotliSettings = true;
    proxyTimeout = "600s";
    commonHttpConfig = ''
      log_format json_combined escape=json '{${jsonFields}}';
      access_log /var/log/nginx/access.log json_combined;
      set_real_ip_from 127.0.0.1;
    '';
    virtualHosts."nginx-status.local" = {
      listen = [
        {
          addr = "127.0.0.1";
          port = 8080;
          ssl = false;
        }
      ];
      locations."/nginx_status" = {
        extraConfig = ''
          stub_status on;
          access_log off;
        '';
      };
    };
  };
  users.users.nginx.extraGroups = [ "acme" ];
  security.acme = {
    acceptTerms = true;
    defaults.email = "freopen@freopen.org";
  };
  environment.persistence."/nix/persist".directories = [ "/var/lib/acme" ];
  services.prometheus.exporters = {
    nginx = {
      enable = true;
      listenAddress = "127.0.0.1";
      scrapeUri = "http://127.0.0.1:8080/nginx_status";
    };
    nginxlog = {
      enable = true;
      listenAddress = "127.0.0.1";
      group = "nginx";
      settings.namespaces = [
        {
          name = "nginx";
          source.files = [ "/var/log/nginx/access.log" ];
          format = "{${jsonFields}}";
          labels = {
            app = "nginx";
          };
          histogram_buckets = [
            0.005
            0.01
            0.025
            0.05
            0.1
            0.25
            0.5
            1
            2.5
            5
            10
          ];
        }
      ];
    };
  };
  services.grafana-alloy-freopen.metrics = {
    nginx = 9113;
    nginxlog = 9117;
  };
}
