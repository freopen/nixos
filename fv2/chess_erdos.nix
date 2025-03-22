{ chess_erdos, ... }:
{
  imports = [
    chess_erdos.nixosModules.default
  ];
  services.chess_erdos = {
    enable = true;
  };
  environment.persistence."/nix/persist".directories = [
    {
      directory = "/var/lib/chess_erdos";
      user = "chess_erdos";
      group = "chess_erdos";
      mode = "0750";
    }
  ];
  services.netdata.metrics.chess_erdos = 4001;
  # services.nginx.virtualHosts."freopen.org" = {
  #   forceSSL = true;
  #   enableACME = true;
  #   locations."/" = {
  #     proxyPass = "http://127.0.0.1:3001/";
  #   };
  #   extraConfig = ''
  #     ssl_client_certificate ${../common/cloudflare_auth_origin_pull.pem};
  #     ssl_verify_client on;
  #   '';
  # };
}
