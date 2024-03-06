{ pkgs, lib, ... }: {
  services.netdata = {
    enable = true;
    package = pkgs.netdata;
    config = {
      web.mode = "none";
      db = {
        mode = "ram";
        "update every" = 60;
        retention = 60 * 60;
      };
      ml.enabled = false;
    };
    configDir = builtins.mapAttrs (file: config:
      builtins.toFile (builtins.baseNameOf file)
      (lib.generators.toINI { } config)) {
        "stream.conf".stream = {
          enabled = true;
          destination = "127.0.0.1:19999";
          "api key" = "fc4f3cb4-a7ac-4c86-8ff8-308cb3310d83";
        };
      };

  };
}
