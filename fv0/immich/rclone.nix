{ config, lib, pkgs, ... }:
let
  rcloneConfig = builtins.toFile "rclone.conf" (lib.generators.toINI { } {
    gcs = {
      type = "gcs";
      service_account_file = config.age.secrets.google_cloud_storage.path;
      no_check_bucket = true;
      bucket_policy_only = true;
    };
    crypt = {
      type = "crypt";
      remote = "gcs:immich";
      filename_encryption = "off";
    };
  });
in {
  age.secrets.rclone = {
    file = ../../secrets/rclone.age;
    owner = "immich-rclone";
    group = "immich-rclone";
  };
  age.secrets.google_cloud_storage = {
    file = ../../secrets/google_cloud_storage.age;
    owner = "immich-rclone";
    group = "immich-rclone";
  };
  users = {
    users.immich-rclone = {
      isSystemUser = true;
      group = "immich-rclone";
      extraGroups = [ "immich" ];
    };
    groups.immich-rclone.members = [ "immich" ];
  };
  systemd.tmpfiles.rules = [ "d /var/lib/immich/cloud 0770 immich immich" ];
  environment.systemPackages = [ pkgs.fuse3 ];
  programs.fuse.userAllowOther = true;
  systemd.services.immich-rclone = {
    after = [ "network-online.target" "run-wrappers.mount" ];
    wants = [ "network-online.target" ];
    requires = [ "run-wrappers.mount" ];
    path = [ "/run/wrappers" ];
    serviceConfig = {
      User = "immich-rclone";
      Type = "notify";
      EnvironmentFile = config.age.secrets.rclone.path;
      StateDirectory = "immich-rclone";
      StateDirectoryMode = "0700";
      ExecStart =
        "${pkgs.rclone}/bin/rclone mount crypt: /var/lib/immich/cloud "
        + lib.cli.toGNUCommandLineShell { } {
          rc = true;
          rc-enable-metrics = true;
          config = rcloneConfig;
          cache-dir = "/var/lib/immich-rclone";
          allow-other = true;
          dir-perms = "0770";
          file-perms = "0660";
          umask = "0000";
          vfs-cache-mode = "full";
          vfs-cache-min-free-space = "10G";
          vfs-cache-max-age = "720d";
          dir-cache-time = "720d";
          poll-interval = 0;
          vfs-fast-fingerprint = true;
          no-modtime = true;
          transfers = 1;
          tpslimit = 1;
          tpslimit-burst = 1000;
        };
      Restart = "on-failure";
      TimeoutStartSec = 60 * 60;
    };
  };
  networking.nftables.preCheckRuleset =
    "sed 's/skuid immich-rclone/skuid nobody/g' -i ruleset.conf";
  networking.nftables.tables.ratelimit = {
    name = "ratelimit";
    family = "inet";
    content = ''
      limit lim_gcp {
        rate over 100 kbytes/second burst 1024 mbytes
      }
      chain immich-rclone {
        type filter hook input priority filter; policy accept;
        meta skuid immich-rclone ct direction reply limit name "lim_gcp" log drop
      }
    '';
  };
}
