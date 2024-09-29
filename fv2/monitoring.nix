{ ... }:
{
  services.netdata = {
    enable = true;
    isParent = true;
    persistDir = "/nix/persist";
  };
}
