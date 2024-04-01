{ pkgs, ... }: {
  services.xserver = {
    enable = true;
    desktopManager.gnome.enable = true;
    displayManager.gdm.enable = true;
  };
  # Gnome sets it to mkDefault true for some reason
  hardware.pulseaudio.enable = false;
  home-manager.users.freopen = {
    home.packages = (with pkgs; [ gnome.gnome-tweaks qalculate-gtk ])
      ++ (with pkgs.gnomeExtensions; [
        dash-to-panel
        clipboard-indicator
        power-profile-switcher
        vitals
      ]);
  };
}
