{ config, pkgs, ... }: {
  boot = {
    kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
    supportedFilesystems = [ "zfs" ];
    zfs.forceImportRoot = false;
    zfs.extraPools = [ "storage" ];
  };
  networking.hostId = "e0488d0f";
  users = {
    users = {
      storage-freopen = {
        isNormalUser = true;
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIODN8vHk/HWHOH9vdV4/3LKoLdk13WiSmGEvYgSmt2va storage-freopen"
        ];
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
