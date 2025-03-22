{ ... }:
{
  services.grafana-alloy-freopen.enable = true;
  services.netdata = {
    enable = true;
    isParent = true;
    persistDir = "/nix/persist";
  };
  environment.persistence."/nix/persist".directories = [
    {
      directory = "/var/lib/grafana-alloy";
      user = "grafana-alloy";
      group = "grafana-alloy";
      mode = "0750";
    }
  ];
}
