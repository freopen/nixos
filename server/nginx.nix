{ ... }: {
  networking.firewall.allowedTCPPorts = [ 80 443 ];
  services.nginx = {
    enable = true;
    virtualHosts."freopen.org" = {
      forceSSL = true;
      enableACME = true;
      locations."/" = { proxyPass = "http://127.0.0.1:3001/"; };
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
