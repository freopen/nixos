{
  pkgs,
  lib,
  config,
  ...
}:
{
  options = {
    services.grafana-alloy-freopen.enable = lib.mkEnableOption "";
  };
  config = lib.mkIf config.services.grafana-alloy-freopen.enable {
    users.users.grafana-alloy = {
      isSystemUser = true;
      group = "grafana-alloy";
      extraGroups = [ "systemd-journal" ];
    };
    users.groups.grafana-alloy = { };
    age.secrets.grafana = {
      file = ../secrets/grafana.age;
      owner = "grafana-alloy";
    };
    systemd.services.grafana-alloy = {
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        User = "grafana-alloy";
        ExecStart = ''
          ${pkgs.unstable.grafana-alloy}/bin/alloy \
            run ${./config.alloy} \
            --storage.path /var/lib/grafana-alloy
        '';
        Restart = "always";
        StateDirectory = "grafana-alloy";
      };
    };
  };
}
