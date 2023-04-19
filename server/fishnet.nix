{ pkgs, config, ... }: {
  age.secrets.fishnet = {
    file = ../secrets/fishnet.age;
    owner = "fishnet";
    group = "fishnet";
  };
  users.groups.fishnet = { };
  users.users.fishnet = {
    isSystemUser = true;
    createHome = true;
    home = "/var/lib/fishnet";
    group = "fishnet";
  };
  systemd.services.fishnet = {
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    environment = { HOME = "/var/lib/fishnet"; };
    serviceConfig = {
      User = "fishnet";
      ExecStart =
        "${pkgs.fishnet}/bin/fishnet --key-file ${config.age.secrets.fishnet.path} --cores 4 run";
      Restart = "always";
      Nice = 5;
      WorkingDirectory = "/var/lib/fishnet";
      PrivateTmp = true;
    };
  };

}
