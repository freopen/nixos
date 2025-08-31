{
  pkgs,
  lib,
  home-manager,
  ...
}:
{
  imports = [
    home-manager.nixosModules.home-manager
    ./dev.nix
    ./firefox.nix
    ./fonts.nix
    ./gaming.nix
    ./kde.nix
    ./networking.nix
  ];
  boot = {
    # kernelPackages = pkgs.linuxKernel.packages.linux_zen;
    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot = {
        enable = true;
      };
      timeout = 1;
    };
  };
  hardware = {
    enableAllFirmware = true;
    bluetooth = {
      enable = true;
      settings = {
        General.Experimental = true;
      };
    };
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
