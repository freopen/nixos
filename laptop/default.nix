{ pkgs, lib, config, modulesPath, home-manager, ... }: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    home-manager.nixosModules.home-manager
    ./sway.nix
    ./dev.nix
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
      grub = {
        enable = true;
        devices = [ "nodev" ];
        efiSupport = true;
        useOSProber = true;
        configurationLimit = 5;
      };
    };
  };
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/nixos";
      fsType = "btrfs";
    };
    "/boot" = {
      device = "/dev/disk/by-label/SYSTEM_DRV";
      fsType = "vfat";
    };
  };
  networking.hostName = "laptop";
  networking.networkmanager.enable = true;
  hardware.cpu.amd.updateMicrocode =
    config.hardware.enableRedistributableFirmware;
  hardware.video.hidpi.enable = true;

  services = {
    printing.enable = true;
    pipewire = {
      enable = true;
      pulse.enable = true;
    };
  };

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
        packages = with pkgs; [
          brightnessctl
          firefox-wayland
          alacritty
          hack-font
        ];
      };
      programs.home-manager.enable = true;
    };
  };
}
