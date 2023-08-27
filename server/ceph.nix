{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [ ceph ];
  networking.firewall.allowedTCPPorts = [ 3300 ];
  networking.firewall.allowedTCPPortRanges = [{
    from = 6800;
    to = 7300;
  }];
  services.ceph = {
    enable = false;
    global = {
      fsid = "29e23744-732b-4bfb-ab1e-a6cc54bead2b";
      monInitialMembers = "fv0";
      monHost = "38.242.213.220";
    };
    mon = {
      enable = true;
      daemons = [ "fv0" ];
    };
    mgr = {
      enable = true;
      daemons = [ "fv0" ];
    };
    rgw = {
      enable = true;
      daemons = [ "fv0" ];
    };
    client = {
      enable = true;
      extraConfig = {
        "client.radosgw.fv0" = {
          rgw_frontends = "beast endpoint=127.0.0.1:7480";
        };
      };
    };
    extraConfig = {
      ms_bind_ipv6 = "true";
      ms_bind_msgr1 = "false";
      ms_bind_msgr2 = "true";
      keyring = "/var/lib/ceph/keyring/$cluster.$name.keyring";
      osd_pool_default_size = "1";
      osd_pool_default_min_size = "1";
    };
  };
}
