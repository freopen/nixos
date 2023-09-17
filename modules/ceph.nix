{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [ ceph ];
  networking.firewall.allowedTCPPorts = [ 3300 ];
  networking.firewall.allowedTCPPortRanges = [{
    from = 6800;
    to = 7300;
  }];
  services.ceph = {
    enable = true;
    global = {
      fsid = "01b48eda-04e2-46d2-9652-b36f4c3d1145";
      monInitialMembers = builtins.concatStringsSep "," [ "cv0" "fp0" "fv0" ];
      monHost = builtins.concatStringsSep "," [
        "2a02:c207:3011:6723::c0:1"
        "2001:1620:5114:0:da3a:ddff:fe18:73f7"
        "2a02:c206:2101:9040::1"
      ];
    };
    extraConfig = {
      ms_bind_ipv4 = "false";
      ms_bind_ipv6 = "true";
      ms_bind_msgr1 = "false";
      ms_bind_msgr2 = "true";
      osd_pool_default_size = "2";
      osd_pool_default_min_size = "2";
    };
  };
}
