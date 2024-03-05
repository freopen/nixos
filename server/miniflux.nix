{ config, ... }: {
  age.secrets.miniflux.file = ../secrets/miniflux.age;
  users.users.miniflux = {
    isSystemUser = true;
    group = "miniflux";
  };
  users.groups.miniflux = { };
  services.miniflux = {
    enable = true;
    config = {
      LISTEN_ADDR = "127.0.0.1:6000";
      BASE_URL = "https://rss.freopen.org";
      CLEANUP_ARCHIVE_UNREAD_DAYS = "-1";
      CLEANUP_ARCHIVE_READ_DAYS = "730";
    };
    adminCredentialsFile = config.age.secrets.miniflux.path;
  };
  services.nginx.virtualHosts."rss.freopen.org" = {
    forceSSL = true;
    useACMEHost = "freopen.org";
    locations."/".proxyPass = "http://127.0.0.1:6000/";
  };
}
