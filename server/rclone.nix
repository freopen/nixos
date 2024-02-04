{ config, lib, pkgs, ... }:
let
  rcloneConfig = builtins.toFile "rclone.conf" (lib.generators.toINI { } {
    storage-freopen = {
      type = "sftp";
      host = "fp0.freopen.org";
      user = "storage-freopen";
      key_file = config.age.secrets.storage-freopen.path;
      shell_type = "unix";
      md5sum_command = "md5sum";
      sha1sum_command = "sha1sum";
      copy_is_hardlink = "true";
    };
    # storage-encrypted = {
    #   type = "union";
    #   upstreams = "storage-freopen:";
    #   action_policy = "all";
    #   create_policy = "all";
    #   search_policy = "ff";
    # };
    storage = {
      type = "crypt";
      remote = "storage-freopen:fv0";
      filename_encoding = "base64";
    };
  });
in {
  age.secrets.storage-freopen.file = ../secrets/storage-freopen.age;
  age.secrets.rclone.file = ../secrets/rclone.age;
  systemd.services.rclone = {
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    path = [ pkgs.fuse3 ];
    serviceConfig = {
      Type = "notify";
      EnvironmentFile = config.age.secrets.rclone.path;
      ExecStart = ''
        ${pkgs.rclone}/bin/rclone mount \
          storage: /rclone \
          --config ${rcloneConfig} \
          --cache-dir /var/lib/rclone \
          --allow-other \
          --dir-cache-time 30d \
          --poll-interval 0 \
          --vfs-cache-mode full \
          --vfs-cache-max-age 30d \
          --vfs-cache-min-free-space 10G
      '';
      ExecStop = "fusermount -u /rclone";
      Restart = "on-failure";
    };
  };
}
