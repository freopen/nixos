{ config, lib, ... }:
{
  networking.firewall.allowedTCPPorts = [
    80
    443
  ];
  services.nginx = {
    enable = true;
    enableReload = true;
    recommendedTlsSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedGzipSettings = true;
    recommendedBrotliSettings = true;
    recommendedZstdSettings = true;
    proxyTimeout = "600s";
    virtualHosts."clickhouse.freopen.org" = {
      forceSSL = true;
      useACMEHost = "clickhouse.freopen.org";
      locations."/" = {
        proxyPass = "http://127.0.0.1:8123/";
      };
    };
  };
  users.users.nginx.extraGroups = [ "acme" ];
  security.acme = {
    acceptTerms = true;
    defaults.email = "freopen@freopen.org";
    certs."freopen.org" = {
      webroot = "/var/lib/acme/acme-challenge";
      extraDomainNames = builtins.attrNames (
        lib.attrsets.filterAttrs (
          domain: vhost: vhost.useACMEHost == "freopen.org" && domain != "freopen.org"
        ) config.services.nginx.virtualHosts
      );
    };
  };
}
