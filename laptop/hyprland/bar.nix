{ pkgs, hyprland, ... }: {
  nixpkgs.overlays = [ hyprland.overlays.hyprland-extras ];
  home-manager.users.freopen = { config, ... }: {
    programs.waybar = {
      enable = true;
      package = pkgs.waybar-hyprland;
      systemd.enable = true;
      settings = [{
        layer = "top";
        position = "bottom";
        modules-left = [ "wlr/workspaces" ];
        modules-center = [ "hyprland/window" ];
        modules-right = [
          "cpu"
          "temperature"
          "memory"
          "disk"
          "backlight"
          "wireplumber"
          "battery"
          "hyprland/language"
          "tray"
          "clock"
        ];
        "wlr/workspaces" = { on-click = "activate"; };
        cpu = {
          interval = 1;
          format = "{icon} {usage:2}% {load:3.1Lf}";
          format-icons = [ "󰡳" "󰡵" "󰊚" "󰡴" ];
        };
        memory = { format = "󰍛 {percentage}% {swapPercentage}%"; };
        disk = { format = "󰋊 {free:2}"; };
        backlight = {
          format = "{icon} {percent}%";
          format-icons = [ "󰃞" "󰃟" "󰃠" ];
          on-scroll-up = "${pkgs.brightnessctl}/bin/brightnessctl set +5%";
          on-scroll-down = "${pkgs.brightnessctl}/bin/brightnessctl set 5%-";
        };
        wireplumber = {
          format = "󱄠 {volume}%";
          format-muted = "󰸈 {volume}%";
          on-click =
            "${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
          on-scroll-up =
            "${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+";
          on-scroll-down =
            "${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";
        };
        battery = {
          format = "{icon} {capacity}% {power}W{time}";
          format-icons = [ "" "" "" "" "" ];
          format-time = " {H}:{M}";
        };
        "hyprland/language" = {
          format-en = "en";
          format-ru = "ru";
        };
        clock = {
          interval = 1;
          format = "{:%a %F %T}";
        };
      }];
      style = ./waybar-style.css;
    };
  };
}
