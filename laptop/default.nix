{
  pkgs,
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
    home-manager.nixosModules.home-manager
    ./dev.nix
    ./firefox.nix
    ./fonts.nix
    ./gaming.nix
    ./gnome.nix
    ./networking.nix
  ];
  boot = {
    initrd.availableKernelModules = [
      "nvme"
      "xhci_pci"
      "thunderbolt"
      "usb_storage"
      "usbhid"
      "sd_mod"
      "sdhci_pci"
    ];
    kernelPackages = pkgs.linuxKernel.packages.linux_zen;
    kernelModules = [ "kvm-amd" ];
    kernelParams = lib.mkIf (lib.versionOlder config.boot.kernelPackages.kernel.version "6.13") [
      # https://bbs.archlinux.org/viewtopic.php?id=301280
      "amdgpu.dcdebugmask=0x10"
    ];
    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot = {
        enable = true;
        configurationLimit = 2;
      };
      timeout = 1;
    };
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
    enableAllFirmware = true;
    cpu.amd.updateMicrocode = true;
    bluetooth = {
      enable = true;
      settings = {
        General.Experimental = true;
      };
    };
    sensor.iio.enable = true;
  };
  security.rtkit.enable = true;

  services = {
    fwupd.enable = true;
    printing.enable = true;
    pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
    };
  };
  system.autoUpgrade = {
    persistent = false;
    operation = "boot";
  };
  systemd.timers.nixos-upgrade = {
    timerConfig.OnBootSec = "1h";
    wantedBy = [ "timers.target" ];
  };
  systemd.services.nixos-upgrade.startAt = lib.mkForce [ ];
  users.users.freopen = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.freopen = {
      home = {
        username = "freopen";
        homeDirectory = "/home/freopen";
        stateVersion = "22.05";
      };
      programs.home-manager.enable = true;
    };
  };
}
