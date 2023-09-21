{ pkgs, ... }: {
  imports = [ ../modules/ceph.nix ];
  networking.firewall.allowedTCPPorts = [ 8443 ];
  services.ceph = {
    mon = {
      enable = true;
      daemons = [ "fp0" ];
    };
    mgr = {
      enable = true;
      daemons = [ "fp0" ];
    };
    osd = {
      enable = true;
      daemons = [ "1" ];
    };
  };
  systemd.services.ceph-volumes = {
    wants = [ "local-fs.target" ];
    after = [ "local-fs.target" ];
    wantedBy = [ "ceph-osd-1.service" ];
    before = [ "ceph-osd-1.service" ];
    path = with pkgs; [ ceph util-linux lvm2 ];
    script = "ceph-volume lvm activate --all --no-systemd";
    serviceConfig = { Type = "oneshot"; };
  };
}
