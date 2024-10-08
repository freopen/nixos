{ pkgs, ... }:
{
  services.xserver = {
    enable = true;
    desktopManager.gnome.enable = true;
    displayManager.gdm.enable = true;
  };
  services.displayManager.defaultSession = "gnome";
  # Gnome sets it to mkDefault true for some reason
  hardware.pulseaudio.enable = false;
  home-manager.users.freopen = {
    home.packages =
      (with pkgs; [
        gnome.gnome-tweaks
        qalculate-gtk
      ])
      ++ (with pkgs.gnomeExtensions; [
        clipboard-indicator
        dash-to-panel
        gtile
        power-profile-switcher
        vitals
      ]);
  };
}
