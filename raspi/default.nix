{ nixos-hardware, ... }: {
  imports = [ nixos-hardware.nixosModules.raspberry-pi-4 ];
  fileSystems."/" = {
    device = "/dev/mmcblk0p2";
    fsType = "ext4";
    options = [ "noatime" ];
  };
  fileSystems."/boot" = {
    device = "/dev/mmcblk0p1";
    fsType = "vfat";
  };

  networking.hostName = "raspi";
  # environment.noXlibs = true;
  system.autoUpgrade = {
    enable = false;
    dates = "Sat, 09:00";
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
