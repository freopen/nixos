{ pkgs, ... }:
{
  hardware.opengl.extraPackages = with pkgs; [
    vaapiVdpau
    libvdpau-va-gl
  ];
  environment.systemPackages = with pkgs; [
    libva-utils
    vdpauinfo
  ];
  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "radeonsi";
    VDPAU_DRIVER = "radeonsi";
  };
  systemd.user.tmpfiles.users.freopen.rules = [ "e /home/freopen/Downloads - - - 90d -" ];
  home-manager.users.freopen.programs.firefox.enable = true;
}
