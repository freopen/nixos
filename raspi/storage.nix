{ pkgs, ... }: {
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.forceImportRoot = false;
  boot.zfs.extraPools = [ "storage" ];
  networking.hostId = "e0488d0f";
  users = {
    users = {
      storage-freopen = {
        isNormalUser = true;
        openssh.authorizedKeys.keys = [ ];
        home = "/storage/freopen";
        createHome = true;
        group = "storage-freopen";
        shell = pkgs.bashInteractive;
      };
      storage-citxx = {
        isNormalUser = true;
        openssh.authorizedKeys.keys = [ ];
        home = "/storage/citxx";
        createHome = true;
        group = "storage-citxx";
        shell = pkgs.bashInteractive;
      };
    };
    groups = {
      storage-freopen = { };
      storage-citxx = { };
    };
  };
}
