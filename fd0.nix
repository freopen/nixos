{ nixos-hardware, ... }:
{
  imports = [
    nixos-hardware.nixosModules.common-cpu-intel-cpu-only
    nixos-hardware.nixosModules.common-gpu-nvidia-nonprime
    nixos-hardware.nixosModules.common-pc
    nixos-hardware.nixosModules.common-pc-ssd
    "${nixos-hardware}/common/gpu/nvidia/ampere"
    ./common
    ./desktop
  ];
  networking.hostName = "fd0";
  fileSystems."/" = {
    device = "/dev/disk/by-label/NIXOS";
    fsType = "btrfs";
    options = [
      "subvol=@"
    ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/BOOT";
    fsType = "vfat";
    options = [
      "fmask=0077"
      "dmask=0077"
    ];
  };
  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 16 * 1024;
    }
  ];
}
