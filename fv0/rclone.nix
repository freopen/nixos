{ config, lib, pkgs, ... }:
let
  rcloneConfig = builtins.toFile "rclone.conf" (lib.generators.toINI { } {
    sia = {
      type = "s3";
      provider = "Other";
      endpoint = "http://127.0.0.1:3200";
      acl = "private";
    };
    storage = {
      type = "crypt";
      remote = "sia:fv0";
      filename_encoding = "base64";
    };
  });
in {
  age.secrets.rclone = {
    file = ../secrets/rclone.age;
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
    after = [ "network-online.target" "run-wrappers.mount" ];
    wants = [ "network-online.target" ];
    requires = [ "run-wrappers.mount" ];
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
          --dir-cache-time 720d \
          --poll-interval 0 \
          --vfs-fast-fingerprint \
          --vfs-cache-mode full \
          --vfs-cache-max-age 720d \
          --vfs-cache-min-free-space 10G
      '';
      ExecStop = "fusermount -u /rclone";
      Restart = "on-failure";
      TimeoutStartSec = 60 * 60;
    };
  };
}
