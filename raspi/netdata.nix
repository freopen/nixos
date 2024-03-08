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
}
