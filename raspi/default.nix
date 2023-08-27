{ nixos-hardware, ... }: {
  imports = [ nixos-hardware.nixosModules.raspberry-pi-4 ./ceph.nix ];
  fileSystems."/" = {
    device = "/dev/mmcblk0p2";
    fsType = "ext4";
    options = [ "noatime" ];
  };
  fileSystems."/boot/firmware" = {
    device = "/dev/mmcblk0p1";
    fsType = "vfat";
  };
  powerManagement.cpuFreqGovernor = "ondemand";
  networking.hostName = "fp0";
  system.autoUpgrade = {
    enable = true;
    dates = "Sat, 03:00";
    flake = "github:freopen/nixos";
    flags = [ "--no-write-lock-file" ];
    allowReboot = true;
  };
  services.openssh = {
    enable = true;
    settings = {
      X11Forwarding = false;
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB0xybsoHuUubvYkoOBNbrqz7CQmRjGIru4HMq/x0Zxo freopen@FREOPEN-DESKTOP"
  ];
  # age.identityPaths = [ "/root/.ssh/id_ed25519" ];
}
