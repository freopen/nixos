{ config, pkgs, const, ... }: {
  boot = {
    # kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
    # supportedFilesystems = [ "zfs" ];
    # zfs.forceImportRoot = false;
    # zfs.extraPools = [ "storage" ];
  };
  # networking.hostId = "e0488d0f";
  # services.zfs = {
  #   autoScrub = {
  #     # enable = true;
  #     interval = "Wed *-*-* 14:00:00";
  #   };
  # };
  services.sanoid = {
    # enable = true;
    interval = "*-*-* 14:00:00";
    datasets.storage = {
      autosnap = true;
      autoprune = true;
      prune_defer = 80;
      frequently = 0;
      hourly = 0;
      daily = 30;
      weekly = 12;
      monthly = 12;
      yearly = 0;
    };
  };
  users = {
    users = {
      storage-freopen = {
        isNormalUser = true;
        # openssh.authorizedKeys.keys = [ const.ssh.storage-freopen ];
        home = "/tmp";
        # home = "/storage/freopen";
        # createHome = true;
        group = "storage-freopen";
        shell = pkgs.bashInteractive;
      };
      #   storage-citxx = {
      #     isNormalUser = true;
      #     openssh.authorizedKeys.keys = [ ];
      #     # home = "/storage/citxx";
      #     # createHome = true;
      #     group = "storage-citxx";
      #     shell = pkgs.bashInteractive;
      #   };
    };
    groups = {
      storage-freopen = { };
      storage-citxx = { };
    };
  };
}
