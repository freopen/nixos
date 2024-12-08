{ config, ... }:
{
  age.secrets.fp0_restic = {
    file = ../../secrets/fp0_restic.age;
    owner = "restic";
  };
  users.users.restic = {
    isSystemUser = true;
    group = "restic";
    extraGroups = [
      "hass"
      "mosquitto"
      "zigbee2mqtt"
    ];
  };
  users.groups.restic = { };
  services.restic.backups.fp0 = {
    user = "restic";
    timerConfig = {
      OnCalendar = "daily";
      Persistent = true;
      RandomizedDelaySec = "6h";
    };
    repository = "s3:https://b8ff5676aceb94ed88fc4b5a2f7a2658.r2.cloudflarestorage.com/fp0-restic";
    passwordFile = "";
    environmentFile = config.age.secrets.fp0_restic.path;
    paths = [
      "/var/lib/hass"
      "/var/lib/mosquitto"
      "/var/lib/zigbee2mqtt"
    ];
    pruneOpts = [
      "--keep-daily 7"
      "--keep-weekly 4"
      "--keep-monthly 12"
    ];
  };
}
