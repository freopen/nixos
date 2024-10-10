{ pkgs, config, ... }:
{
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
  environment.persistence."/nix/persist".directories = [
    {
      directory = "/var/lib/fishnet";
      user = "fishnet";
      group = "fishnet";
      mode = "0750";
    }
  ];
  systemd.services.fishnet = {
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    environment = {
      HOME = "/var/lib/fishnet";
    };
    script = ''
      if [ ! -f "/var/lib/fishnet/fishnet" ]; then
        ${pkgs.curl}/bin/curl https://fishnet-releases.s3.dualstack.eu-west-3.amazonaws.com/v2.9.4/fishnet-x86_64-unknown-linux-musl --output /var/lib/fishnet/fishnet
        chmod +x /var/lib/fishnet/fishnet
      fi
      exec /var/lib/fishnet/fishnet --auto-update --key-file ${config.age.secrets.fishnet.path} --cores all run
    '';
    serviceConfig = {
      User = "fishnet";
      Restart = "always";
      KillMode = "mixed";
      CPUSchedulingPolicy = "idle";
      IOSchedulingClass = "idle";
      Nice = 19; # To mark process as nice for monitoring
      WorkingDirectory = "/var/lib/fishnet";
      PrivateTmp = true;
    };
  };
}
