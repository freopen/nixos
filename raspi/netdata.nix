{ pkgs, config, ... }: {
  age.secrets.netdata_stream_fp0 = {
    file = ../secrets/netdata_stream_fp0.age;
    owner = "netdata";
    group = "netdata";
  };
  services.netdata = {
    enable = true;
    package = pkgs.netdata;
    config = {
      web.mode = "none";
      db = {
        mode = "ram";
        "update every" = 10;
        retention = 24 * 60 * 60 / 10;
      };
      ml.enabled = false;
    };
    configDir = { "stream.conf" = config.age.secrets.netdata_stream_fp0.path; };
  };
  environment.persistence."/persist".files =
    [ "/var/lib/netdata/registry/netdata.public.unique.id" ];
  systemd.tmpfiles.rules = [ "d /var/log/smartd 0750 root netdata - -" ];
  services.smartd = {
    enable = true;
    extraOptions =
      [ "-A /var/log/smartd/" "--interval=${builtins.toString (4 * 60 * 60)}" ];
  };
}
