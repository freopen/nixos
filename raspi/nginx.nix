{ ... }: {
  networking.firewall.allowedTCPPorts = [ 80 443 ];
  services.nginx = {
    enable = true;
    # recommendedTlsSettings = true;
    # recommendedOptimisation = true;
    # recommendedProxySettings = true;
    # recommendedGzipSettings = true;
    # recommendedBrotliSettings = true;
    # recommendedZstdSettings = true;
  };
  security.acme = {
    acceptTerms = true;
    defaults.email = "freopen@freopen.org";
  };
  environment.persistence."/persist" = { directories = [ "/var/lib/acme" ]; };
}
