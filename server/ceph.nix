{ ... }: {
  imports = [ ../modules/ceph.nix ];
  services.ceph = {
    mon = {
      enable = true;
      daemons = [ "fv0" ];
    };
    mgr = {
      enable = true;
      daemons = [ "fv0" ];
    };
    rgw = {
      enable = false;
      daemons = [ "fv0" ];
    };
    client = {
      enable = false;
      extraConfig = {
        "client.radosgw.fv0" = {
          rgw_frontends = "beast endpoint=127.0.0.1:7480";
        };
      };
    };
  };
}
