{ config, lib, pkgs, ... }:
let
  rcloneConfig = builtins.toFile "rclone.conf" (lib.generators.toINI { } {
    storage-freopen = {
      type = "sftp";
      host = "fp0.freopen.org";
      user = "storage-freopen";
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
  age.secrets.rclone = {
    file = ../secrets/rclone.age;
    mode = "600";
    owner = "rclone";
    group = "rclone";
  };
  users.users.rclone = {
    isSystemUser = true;
    group = "rclone";
    extraGroups = [ "mounters" ];
  };
  users.groups.rclone = { };
  users.groups.mounters = { };
  environment.systemPackages = [ pkgs.fuse3 ];
  programs.fuse.userAllowOther = true;
  systemd.tmpfiles.rules =
    [ "d /mnt 0750 root mounters - -" "d /mnt/rclone 0700 rclone rclone - -" ];
  systemd.services.rclone = {
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    path = [ "/run/wrappers" ];
    serviceConfig = {
      User = "rclone";
      Type = "notify";
      EnvironmentFile = config.age.secrets.rclone.path;
      StateDirectory = "rclone";
      StateDirectoryMode = "0700";
      ExecStart = ''
        ${pkgs.rclone}/bin/rclone mount \
          storage: /mnt/rclone \
          --rc \
          --rc-enable-metrics \
          --config ${rcloneConfig} \
          --cache-dir /var/lib/rclone \
          --allow-other \
          --dir-perms 0770 \
          --file-perms 0660 \
          --umask 0000 \
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
