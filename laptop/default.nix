{ pkgs, config, modulesPath, home-manager, ... }: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    home-manager.nixosModules.home-manager
    ./dev.nix
    ./firefox.nix
    ./fonts.nix
    ./gaming.nix
    ./hyprland
    ./networking.nix
    ./rofi.nix
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
      timeout = 30;
    };
  };
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
    blueman.enable = true;
    fwupd.enable = true;
    tlp = {
      enable = true;
      settings = {
        CPU_SCALING_GOVERNOR_ON_AC = "performance";
        CPU_SCALING_GOVERNOR_ON_BAT = "schedutil";
        DEVICES_TO_DISABLE_ON_LAN_CONNECT = "wifi";
        DEVICES_TO_ENABLE_ON_LAN_DISCONNECT = "wifi";
        PLATFORM_PROFILE_ON_AC = "performance";
        PLATFORM_PROFILE_ON_BAT = "low-power";
        RESTORE_DEVICE_STATE_ON_STARTUP = 1;
        START_CHARGE_THRESH_BAT0 = 0;
        STOP_CHARGE_THRESH_BAT0 = 1;
      };
    };
    printing.enable = true;
    pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
    };
    greetd = {
      enable = true;
      settings.default_session = {
        command = ''
          bash -c "Hyprland; gamescope --steam -- bash -c 'steam -tenfoot -pipewire-dmabuf & mangohud'"'';
        user = "freopen";
      };
    };
    gnome.gnome-keyring.enable = true;
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
        packages = with pkgs; [ brightnessctl gnome.file-roller xdg-utils ];
      };
      programs.home-manager.enable = true;
    };
  };
}
