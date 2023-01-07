{ pkgs, lib, ... }: {
  home-manager.users.freopen = {
    programs.rofi = {
      enable = true;
      package = pkgs.rofi-wayland;
      plugins = with pkgs; [ rofi-emoji rofi-calc ];
      terminal = "${pkgs.alacritty}/bin/alacritty";
      extraConfig = {
        modi = "combi,calc";
        combi-modi =
          "drun,emoji,power:${pkgs.rofi-power-menu}/bin/rofi-power-menu,run";
      };
    };
    wayland.windowManager.sway = {
      config.keybindings =
        lib.mkOptionDefault { "Mod4+d" = "exec rofi -show combi"; };
    };
  };
}
