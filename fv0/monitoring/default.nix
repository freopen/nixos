{ ... }:
{
  imports = [ ./netdata.nix ];
  services.grafana-alloy-freopen.enable = true;
}
