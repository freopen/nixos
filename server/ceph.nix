{ config, pkgs, ... }: {
  imports = [ ../modules/ceph.nix ];
  # Ceph Dashboard
  networking.firewall.allowedTCPPorts = [ 8100 ];
  services.ceph = {
    mon = {
      enable = true;
      daemons = [ "fv0" ];
    };
    mgr = {
      enable = true;
      daemons = [ "fv0" ];
    };
    rgw = {
      enable = true;
      daemons = [ "fv0" ];
    };
    client = {
      enable = true;
      extraConfig = {
        "client.fv0" = { rgw_frontends = "beast endpoint=127.0.0.1:7480"; };
      };
    };
  };
  environment.systemPackages = [ pkgs.rclone ];
  age.secrets.rclone.file = ../secrets/rclone.age;
  users.groups.ceph-mount = { };
  systemd.tmpfiles.rules = [ "d /mnt/ceph 0770 root ceph-mount - -" ];
  systemd.services.ceph-mount = {
    wants = [ "local-fs.target" ];
    path = [ pkgs.fuse3 ];
    serviceConfig = {
      Type = "notify";
      ExecStart = ''
        ${pkgs.rclone}/bin/rclone mount \
          crypt: /mnt/ceph \
          --config=${config.age.secrets.rclone.path} \
          --cache-dir=/var/cache/rclone \
          --vfs-cache-mode=full \
          --vfs-cache-max-age=30d \
          --vfs-cache-min-free-space 10G
      '';
      ExecStop = "fusermount -u /mnt/ceph";
      Restart = "on-failure";
    };
  };
}
