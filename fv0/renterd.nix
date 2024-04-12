{ pkgs, ... }: {
  networking.firewall.allowedTCPPorts = [ 9981 ];
  age.secrets.renterd = {
    file = ../secrets/renterd.age;
    path = "/var/lib/renterd/renterd.yml";
    owner = "renterd";
    group = "renterd";
  };
  users.users.renterd = {
    isSystemUser = true;
    group = "renterd";
    packages = [ pkgs.renterd ];
  };
  users.groups.renterd = { };
  systemd.services.renterd = {
    enable = true;
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      User = "renterd";
      ExecStart = "${pkgs.renterd}/bin/renterd";
      WorkingDirectory = "/var/lib/renterd";
      StateDirectory = "renterd";
      StateDirectoryMode = "0750";
      Restart = "always";
      RestartSec = 15;
      TimeoutStopSec = 120;
      LogFilterPatterns = "~(HEAD OBJECT)";
    };
  };
}

