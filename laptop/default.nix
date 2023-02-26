{ pkgs, lib, config, modulesPath, home-manager, ... }: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    home-manager.nixosModules.home-manager
    ./bar.nix
    ./dev.nix
    ./fonts.nix
    ./rofi.nix
    ./sway.nix
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
  networking = {
    hostName = "laptop";
    useNetworkd = true;
    wireless.iwd.enable = true;
    nameservers =
      [ "1.1.1.1" "1.0.0.1" "2606:4700:4700::1111" "2606:4700:4700::1001" ];
  };
  systemd.network.wait-online.enable = false;
  hardware.cpu.amd.updateMicrocode =
    config.hardware.enableRedistributableFirmware;
  hardware.video.hidpi.enable = true;
  security.rtkit.enable = true;

  services = {
    fwupd.enable = true;
    tlp.enable = true;
    resolved.dnssec = "true";
    resolved.extraConfig = ''
      [Resolve]
      DNSOverTLS=yes
    '';
    printing.enable = true;
    pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
    };
    greetd = {
      enable = true;
      settings.default_session = {
        command = "sway";
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
        packages = with pkgs; [
          alacritty
          brightnessctl
          firefox-wayland
          gnome.file-roller
          xdg-utils
        ];
      };
      programs.home-manager.enable = true;
    };
  };
}
