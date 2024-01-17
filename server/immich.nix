{ pkgs, ... }: {
  virtualisation.podman = {
    enable = true;
    defaultNetwork.settings.dns_enabled = true;
  };
  users.users.immich = {
    isNormalUser = true;
    group = "immich";
    extraGroups = [ "ceph-mount" ];
    linger = true;
    packages = [ pkgs.podman-compose ];
  };
  users.groups.immich = { };
  services.nginx.virtualHosts."photos.freopen.org" = {
    forceSSL = true;
    enableACME = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:2283/";
      proxyWebsockets = true;
      extraConfig = ''
        client_max_body_size 500M;
        proxy_buffering off;
      '';
    };
  };
}
