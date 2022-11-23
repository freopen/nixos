{ pkgs, lib, config, modulesPath, ... }:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ./sway.nix
    ./dev.nix
    ./shell.nix
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
  fileSystems."/" =
    {
      device = "/dev/disk/by-label/nixos";
      fsType = "btrfs";
    };
  fileSystems."/boot" =
    {
      device = "/dev/disk/by-label/SYSTEM_DRV";
      fsType = "vfat";
    };
  networking.useDHCP = lib.mkDefault true;
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  hardware.video.hidpi.enable = lib.mkDefault true;

  networking.networkmanager.enable = true;

  services = {
    xserver = {
      layout = "us,ru";
      xkbVariant = "altgr-intl,";
      xkbOptions = "compose:rctrl,grp:caps_toggle";
      libinput.enable = true;
    };
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

  home-manager.users.freopen = {
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
}
