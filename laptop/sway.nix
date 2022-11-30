{ pkgs, lib, ... }:
let
  laptop_lid = pkgs.writeScript "laptop_lid" ''
    if [[ $(< /proc/acpi/button/lid/LID0/state) == *"open"* ]];
    then
      ACTION=enable
    else
      ACTION=disable
    fi
    swaymsg output eDP-1 $ACTION
  '';
in {
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
        startup = [{
          command = "${laptop_lid}";
          always = true;
        }];
      };
      extraConfig = ''
        bindswitch lid:toggle exec ${laptop_lid}
      '';
    };
  };
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
}
