{ pkgs, ... }: {
  home-manager.users.freopen = {
    programs.rofi = {
      enable = true;
      package = pkgs.rofi-wayland;
      plugins = with pkgs; [ rofi-emoji rofi-calc ];
      terminal = "${pkgs.foot}/bin/foot";
      extraConfig = {
        modi = "drun,calc,emoji";
        sidebar-mode = true;
        show-icons = true;
      };
    };
  };
}
