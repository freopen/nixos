{
  home-manager,
  lib,
  nixos-hardware,
  config,
  ...
}:
{
  imports = [
    nixos-hardware.nixosModules.common-cpu-amd
    nixos-hardware.nixosModules.common-cpu-amd-pstate
    # nixos-hardware.nixosModules.common-cpu-amd-zenpower
    nixos-hardware.nixosModules.common-gpu-amd
    nixos-hardware.nixosModules.common-pc-laptop
    nixos-hardware.nixosModules.common-pc-laptop-ssd
    ./common
    ./desktop
  ];
  networking.hostName = "laptop";
  boot = {
    loader.systemd-boot.configurationLimit = 2;
    initrd.availableKernelModules = [
      "nvme"
      "xhci_pci"
      "thunderbolt"
      "usb_storage"
      "usbhid"
      "sd_mod"
      "sdhci_pci"
    ];
    kernelModules = [ "kvm-amd" ];
    kernelParams = lib.mkIf (lib.versionOlder config.boot.kernelPackages.kernel.version "6.13") [
      # https://bbs.archlinux.org/viewtopic.php?id=301280
      "amdgpu.dcdebugmask=0x10"
    ];
    # https://github.com/rustwasm/wasm-pack/issues/1356
    # tmp.useTmpfs = true;
  };
  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 16 * 1024;
    }
  ];
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/nixos";
      fsType = "btrfs";
      options = [ "compress-force=zstd" ];
    };
    "/boot" = {
      device = "/dev/disk/by-label/SYSTEM_DRV";
      fsType = "vfat";
    };
  };
  hardware = {
    cpu.amd.updateMicrocode = true;
    sensor.iio.enable = true;
  };
}
