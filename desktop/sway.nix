{ pkgs, ... }:
{
  programs.sway.enable = true;

  home-manager.users.freopen.wayland.windowManager.sway = {
    enable = true;
    config = {
      modifier = "Mod4";
      defaultWorkspace = "workspace number 1";
      terminal = "alacritty";
      window.titlebar = false;
      keybindings = let 
        modifier = config.wayland.windowManager.sway.config.modifier;
      in lib.mkOptionDefault {
        "XF86MonBrightnessUp" = "brightnessctl set +5%";
        "XF86MonBrightnessDown" = "brightnessctl set -5%";
      }; 
    };
  };
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
}
