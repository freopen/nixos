{ self, pkgs, config, modulesPath, home-manager, lib, ... }: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
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
    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot = {
        enable = true;
        configurationLimit = 10;
      };
      timeout = 1;
    };
    # https://github.com/rustwasm/wasm-pack/issues/1356
    # tmp.useTmpfs = true;
  };
  time.timeZone = "Europe/Zurich";
  swapDevices = [{
    device = "/var/lib/swapfile";
    size = 16 * 1024;
  }];
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
    cpu.amd.updateMicrocode = config.hardware.enableRedistributableFirmware;
    bluetooth = {
      enable = true;
      settings = { General.Experimental = true; };
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
    enable = true;
    flake = self.outPath;
    flags = [
      "--update-input"
      "nixpkgs"
      "--no-write-lock-file"
      "-L" # print build logs
    ];
    persistent = false;
    operation = "boot";
  };
  systemd.timers.nixos-upgrade.timerConfig.OnBootSec = "1h";
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
