{ config, lib, ... }:
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
    recommendedZstdSettings = true;
    proxyTimeout = "600s";
    commonHttpConfig =
      let
        json_fields = builtins.concatStringsSep "," (
          builtins.map (field: ''"${field}":"''$${field}"'') [
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
          ]
        );
      in
      ''
        log_format json_combined escape=json '{${json_fields}}';
        access_log syslog:server=unix:/dev/log json_combined;
        set_real_ip_from 127.0.0.1;
      '';
    # virtualHosts.localhost = {
    #   listenAddresses = [ "127.0.0.1" ];
    #   locations."/nginx_status" = {
    #     extraConfig = ''
    #       stub_status on;
    #       access_log off;
    #     '';
    #   };
    # };
  };
  users.users.nginx.extraGroups = [ "acme" ];
  security.acme = {
    acceptTerms = true;
    defaults.email = "freopen@freopen.org";
  };
  environment.persistence."/nix/persist".directories = [ "/var/lib/acme" ];
}
