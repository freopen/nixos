{ ... }:
{
  imports = [ ./rclone.nix ];
  services = {
    immich = {
      enable = true;
      database.enableVectors = true;
    };
    nginx.virtualHosts."photos.freopen.org" = {
      forceSSL = true;
      enableACME = true;
      locations."/" = {
        proxyPass = "http://localhost:2283/";
        proxyWebsockets = true;
        extraConfig = ''
          client_max_body_size 50000M;
          proxy_read_timeout 600s;
          proxy_send_timeout 600s;
          send_timeout 600s;
        '';
      };
    };
  };
  environment.persistence."/nix/persist".directories = [
    "/var/lib/immich"
    "/var/lib/redis-immich"
  ];
  systemd.mounts =
    builtins.map
      (dir: {
        where = "/var/lib/immich/${dir}";
        what = "/var/lib/immich-cloud/${dir}";
        type = "none";
        options = "bind,_netdev";
        after = [ "immich-rclone.service" ];
        bindsTo = [ "immich-rclone.service" ];
        requiredBy = [
          "immich-server.service"
          "immich-machine-learning.service"
        ];
        before = [
          "immich-server.service"
          "immich-machine-learning.service"
        ];
      })
      [
        "library"
        "thumbs"
      ];
  networking.nftables.preCheckRuleset = ''
    sed 's/skuid immich-rclone/skuid nobody/g' -i ruleset.conf
  '';
  networking.nftables.tables.ratelimit = {
    name = "ratelimit";
    family = "inet";
    content = ''
      limit lim_gcp {
        rate over 1000 kbytes/second burst 1024 mbytes
      }
      chain immich {
        type filter hook input priority filter; policy accept;
        meta skuid immich-rclone ct direction reply limit name "lim_gcp" log drop
      }
    '';
  };
  services.netdata.metrics = {
    immich_server = 5004;
    immich_microservices = 5005;
  };
}
