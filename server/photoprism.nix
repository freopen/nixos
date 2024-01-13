{ lib, ... }: {
  services.photoprism = {
    enable = true;
    originalsPath = "/mnt/ceph/photoprism";
  };
  systemd.services.photoprism = {
    wants = [ "ceph-mount.service" ];
    before = [ "ceph-mount.service" ];
    serviceConfig.DynamicUser = lib.mkForce false;
  };
  users.users.photoprism = {
    isSystemUser = true;
    group = "photoprism";
    extraGroups = [ "ceph-mount" ];
  };
  users.groups.photoprism = { };
  services.nginx.virtualHosts."photos.freopen.org" = {
    forceSSL = true;
    enableACME = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:2342/";
      proxyWebsockets = true;
      extraConfig = ''
        client_max_body_size 500M;
        proxy_buffering off;
      '';
    };
  };
}
