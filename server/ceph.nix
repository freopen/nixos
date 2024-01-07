{ ... }: {
  imports = [ ../modules/ceph.nix ];
  # Ceph Dashboard
  networking.firewall.allowedTCPPorts = [ 8100 ];
  services.ceph = {
    mon = {
      enable = true;
      daemons = [ "fv0" ];
    };
    mgr = {
      enable = true;
      daemons = [ "fv0" ];
    };
    mds = {
      enable = true;
      daemons = [ "fv0" ];
      extraConfig = {
        debug_mds = "20";
        debug_monc = "20";
        debug_mds_log = "20";
        debug_auth = "20";
        debug_crypto = "20";
        debug_client = "20";
        debug_default = "20";
      };
    };
  };
}
