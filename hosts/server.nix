{ modulesPath, ... }: {
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];
  boot.loader.grub.device = "/dev/sda";
  boot.initrd.availableKernelModules = [ "ata_piix" "uhci_hcd" "xen_blkfront" ];
  boot.initrd.kernelModules = [ "nvme" ];
  fileSystems."/" = { device = "/dev/sda3"; fsType = "ext4"; };
  boot.cleanTmpDir = true;
  zramSwap.enable = true;
  networking.hostName = "server";
  system.autoUpgrade = {
    enable = true;
    dates = "Sat, 09:00";
    flake = "github:freopen/nixos";
    flags = [ "--no-write-lock-file" ];
    allowReboot = true;
  };
  nix = {
    gc = {
      automatic = true;
      dates = "Sun, 14:00";
      options = "--delete-older-than 30d";
    };
  };
  services.openssh.enable = true;
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB0xybsoHuUubvYkoOBNbrqz7CQmRjGIru4HMq/x0Zxo freopen@FREOPEN-DESKTOP"
  ];
  age.identityPaths = [
    "/root/.ssh/id_ed25519"
  ];
}
