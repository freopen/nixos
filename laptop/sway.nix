{ pkgs, lib, ... }: {
  programs.sway.enable = true;

  home-manager.users.freopen = {
    programs.mako = { enable = true; };
    wayland.windowManager.sway = {
      enable = true;
      config = {
        input."*" = {
          xkb_layout = "us,ru";
          xkb_variant = "altgr-intl,";
          xkb_options = "compose:rctrl,grp:caps_toggle";
          xkb_numlock = "enabled";
        };
        modifier = "Mod4";
        defaultWorkspace = "workspace number 1";
        terminal = "alacritty";
        window = {
          titlebar = false;
          hideEdgeBorders = "both";
        };
        keybindings = lib.mkOptionDefault {
          "XF86MonBrightnessUp" = "brightnessctl set +5%";
          "XF86MonBrightnessDown" = "brightnessctl set -5%";
        };
      };
    };
  };
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
}
