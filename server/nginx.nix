{ ... }: {
  networking.firewall.allowedTCPPorts = [ 80 443 ];
  services.nginx = {
    enable = true;
    virtualHosts."freopen.org" = {
      forceSSL = true;
      enableACME = true;
      locations."/" = { proxyPass = "http://127.0.0.1:3001/"; };
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
        "127.0.0.1:8443" = { };
        "[2001:1620:5114:0:da3a:ddff:fe18:73f7]:8443" = { backup = true; };
      };
    };
  };
  security.acme = {
    acceptTerms = true;
    defaults.email = "freopen@freopen.org";
  };
}
