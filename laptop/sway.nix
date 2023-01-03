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
  security.pam.services.swaylock.enableGnomeKeyring = true;

  home-manager.users.freopen = {
    programs.mako = { enable = true; };
    programs.swaylock.settings = {
      color = "#07260a";
      show-failed-attempts = true;
    };
    programs.i3status-rust = {
      enable = true;
      bars.default = { icons = "material-nf"; };
    };
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
          "Mod4+x" = "exec swaylock";
        };
        startup = [{
          command = "${laptop_lid}";
          always = true;
        }];
        bars = [{
          statusCommand =
            "${pkgs.i3status-rust}/bin/i3status-rs ~/.config/i3status-rust/config-default.toml";

        }];
      };
      extraConfig = ''
        exec swaylock
        bindswitch lid:toggle exec ${laptop_lid}
      '';
    };
    home.pointerCursor = {
      package = pkgs.simp1e-cursors;
      name = "Simp1e-Adw-Dark";
      x11.enable = true;
      gtk.enable = true;
    };
  };
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
}
