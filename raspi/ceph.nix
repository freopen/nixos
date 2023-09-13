{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [ ceph ];
  networking.firewall.allowedTCPPortRanges = [{
    from = 6800;
    to = 7300;
  }];
  services.ceph = {
    enable = true;
    global = {
      fsid = "01b48eda-04e2-46d2-9652-b36f4c3d1145";
      monInitialMembers = builtins.concatStringsSep "," [ "cv0" "fp0" ];
      monHost = builtins.concatStringsSep "," [
        "2a02:c207:3011:6723::c0:1"
        "2001:1620:5114:0:da3a:ddff:fe18:73f7"
      ];
    };
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
    extraConfig = {
      ms_bind_ipv4 = "false";
      ms_bind_ipv6 = "true";
      ms_bind_msgr1 = "false";
      ms_bind_msgr2 = "true";
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
