{ pkgs, ... }:
{
  services.udev.packages = [ pkgs.unstable.game-devices-udev-rules ];
  services.udev.extraRules = ''
    # Flydigi Vader 3 Pro USB Dongle
    SUBSYSTEM=="usb", ATTRS{idVendor}=="04b4", ATTRS{idProduct}=="2412", MODE="0666"
    KERNEL=="hidraw*", ATTRS{idVendor}=="04b4", ATTRS{idProduct}=="2412", MODE="0666"
  '';
  hardware.uinput.enable = true;
  programs.steam = {
    enable = true;
    gamescopeSession = {
      enable = true;
      args = [
        "--mangoapp"
        "-F fsr"
        "-W 2880"
        "-H 1800"
        "-w 1440"
        "-h 900"
      ];
    };
    extest.enable = true;
  };
  programs.gamescope = {
    enable = true;
    capSysNice = true;
  };
  home-manager.users.freopen = {
    programs.mangohud = {
      enable = true;
      settings = {
        toggle_preset = "F11";
        preset = "1,2,3,4";
      };
    };
  };
}
