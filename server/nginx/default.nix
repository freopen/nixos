{ config, ... }: {
  age.secrets.cloudflare_origin_cert = {
    file = ../../secrets/cloudflare_origin_cert.age;
    owner = "nginx";
    group = "nginx";
  };
  networking.firewall.allowedTCPPorts = [ 80 443 ];
  services.nginx = {
    enable = true;
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
    virtualHosts."ceph.freopen.org" = {
      forceSSL = true;
      enableACME = true;
      locations."/" = {
        proxyPass = "https://ceph-dashboard";
        extraConfig = ''
          proxy_ssl_trusted_certificate ${./ceph-dashboard.pem};
          proxy_next_upstream error http_503;
        '';
      };
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
    upstreams.ceph-dashboard = {
      servers = {
        "127.0.0.1:8100" = { };
        "[2a02:c207:3011:6723::c0:1]:8100" = { backup = true; };
      };
    };
  };
  security.acme = {
    acceptTerms = true;
    defaults.email = "freopen@freopen.org";
  };
}
