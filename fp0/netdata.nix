{ pkgs, config, ... }:
{
  age.secrets.netdata_stream_fp0 = {
    file = ../secrets/netdata_stream_fp0.age;
    owner = "netdata";
    group = "netdata";
  };
  services.netdata = {
    enable = true;
    package = pkgs.unstable.netdata;
    config = {
      web.mode = "none";
      db = {
        mode = "ram";
        "update every" = 10;
        retention = 24 * 60 * 60 / 10;
      };
      ml.enabled = false;
    };
    configs = {
      "python.d/smartd_log.conf" = {
        update_every = 60 * 60;
      };
      "stream.conf" = config.age.secrets.netdata_stream_fp0.path;
    };
  };
  environment.persistence."/persist".files = [ "/var/lib/netdata/registry/netdata.public.unique.id" ];
}
