{ pkgs, ... }: {
  home-manager.users.freopen = {
    wayland.windowManager.sway.config.bars = [{
      statusCommand =
        "${pkgs.i3status-rust}/bin/i3status-rs ~/.config/i3status-rust/config-default.toml";
    }];
    programs.i3status-rust = {
      enable = true;
      bars.default = {
        icons = "material-nf";
        blocks = [
          {
            block = "focused_window";
            format = "$visible_marks $title.str(max_w:200)";
          }
          {
            block = "load";
            format = "$icon $1m.eng(w:3) $5m.eng(w:3) $15m.eng(w:3)";
          }
          {
            block = "temperature";
            format = "$icon $max";
          }
          {
            block = "cpu";
            format = "$icon $max_frequency.eng(w:4)";
          }
          {
            block = "amd_gpu";
            format = "$icon $utilization $vram_used_percents";
            interval = 1;
          }
          {
            block = "memory";
            format = "$icon $mem_avail $icon_swap $swap_free_percents";
          }
          {
            block = "disk_space";
            format = "$icon $available";
          }
          {
            block = "net";
            format = "$icon $ssid $signal_strength";
            click = [{
              button = "left";
              cmd = "rfkill toggle wlan";
            }];
          }
          {
            block = "sound";
            format = "$icon $volume";
          }
          {
            block = "backlight";
            format = "$icon $brightness";
          }
          {
            block = "battery";
            format = "$icon $percentage $time $power";
          }
          {
            block = "keyboard_layout";
            driver = "sway";
            format = "$layout.str(max_w:2)";
          }
          {
            block = "time";
            format = "$icon $timestamp.datetime(f:'%a %F %T')";
            interval = 1;
          }
        ];
      };
    };
  };
}
