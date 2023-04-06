{ pkgs, ... }: {
  hardware.opengl.extraPackages = with pkgs; [ vaapiVdpau libvdpau-va-gl ];
  environment.systemPackages = with pkgs; [ libva-utils vdpauinfo ];
  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "radeonsi";
    VDPAU_DRIVER = "radeonsi";
  };
  home-manager.users.freopen.programs.firefox = {
    enable = true;
    package = pkgs.firefox-devedition;
  };
}
