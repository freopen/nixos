{ pkgs, ... }:
{
  imports = [ ./sway.nix ./dev.nix ./shell.nix ];

  boot = {
    # Switch to Zen when 6.0 is released
    kernelPackages = pkgs.linuxKernel.packages.linux_testing;
    loader = {
      efi.canTouchEfiVariables = true;
      grub = {
        enable = true;
        devices = [ "nodev" ];
        efiSupport = true;
        useOSProber = true;
      };
    };
  };

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
