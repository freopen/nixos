{ config, ... }:
{
  age.secrets.miniflux.file = ../secrets/miniflux.age;
  users.users.miniflux = {
    isSystemUser = true;
    group = "miniflux";
  };
  users.groups.miniflux = { };
  services.miniflux = {
    enable = true;
    config = {
      BASE_URL = "https://rss.freopen.org";
      CLEANUP_ARCHIVE_READ_DAYS = 2 * 365;
      CLEANUP_ARCHIVE_UNREAD_DAYS = -1;
      CLEANUP_FREQUENCY_HOURS = 30 * 24;
      LISTEN_ADDR = "127.0.0.1:6000";
      METRICS_COLLECTOR = 1;
      POLLING_PARSING_ERROR_LIMIT = 0;
      POLLING_SCHEDULER = "entry_frequency";
      SCHEDULER_ENTRY_FREQUENCY_MIN_INTERVAL = 60;
    };
    adminCredentialsFile = config.age.secrets.miniflux.path;
  };
  services.nginx.virtualHosts."rss.freopen.org" = {
    forceSSL = true;
    enableACME = true;
    locations."/".proxyPass = "http://127.0.0.1:6000/";
  };
  services.netdata.metrics.miniflux = 6000;
}
