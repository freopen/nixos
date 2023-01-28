{ pkgs, lib, ... }: {
  home-manager.users.freopen = {
    programs.rofi = {
      enable = true;
      package = pkgs.rofi-wayland;
      plugins = with pkgs; [ rofi-emoji rofi-calc ];
      terminal = "${pkgs.alacritty}/bin/alacritty";
      extraConfig = {
        modi = "drun,calc,emoji";
        sidebar-mode = true;
        show-icons = true;
      };
    };
    wayland.windowManager.sway = {
      config.keybindings =
        lib.mkOptionDefault { "Mod4+d" = "exec rofi -show drun"; };
    };
  };
}
