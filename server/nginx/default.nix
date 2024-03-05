{ config, ... }: {
  age.secrets.cloudflare_origin_cert = {
    file = ../../secrets/cloudflare_origin_cert.age;
    owner = "nginx";
    group = "nginx";
  };
  networking.firewall.allowedTCPPorts = [ 80 443 ];
  services.nginx = {
    enable = true;
    recommendedTlsSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedGzipSettings = true;
    recommendedBrotliSettings = true;
    recommendedZstdSettings = true;
    proxyTimeout = "600s";
    virtualHosts."freopen.org" = {
      forceSSL = true;
      sslCertificate = config.age.secrets.cloudflare_origin_cert.path;
      sslCertificateKey = config.age.secrets.cloudflare_origin_cert.path;
      locations."/" = { proxyPass = "http://127.0.0.1:3001/"; };
      extraConfig = ''
        ssl_client_certificate ${./cloudflare_auth_origin_pull.pem};
        ssl_verify_client on;
      '';
    };
    virtualHosts.localhost = {
      listenAddresses = [ "127.0.0.1" ];
      locations."/nginx_status" = {
        extraConfig = ''
          stub_status on;
          access_log off;
        '';
      };
    };
  };
  security.acme = {
    acceptTerms = true;
    defaults.email = "freopen@freopen.org";
  };
}
