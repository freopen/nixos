{ ... }:
{
  networking.firewall.allowedTCPPorts = [
    80
    443
  ];
  services.nginx = {
    enable = true;
    recommendedTlsSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedGzipSettings = true;
    logError = "syslog:server=unix:/dev/log";
    appendHttpConfig = ''
      access_log syslog:server=unix:/dev/log combined;
    '';
  };
  security.acme = {
    acceptTerms = true;
    defaults.email = "freopen@freopen.org";
  };
  environment.persistence."/persist" = {
    directories = [ "/var/lib/acme" ];
  };
}
