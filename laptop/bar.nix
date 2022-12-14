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
            show_marks = "visible";
            max_width = 200;
          }
          {
            block = "load";
            format = "{1m} {5m} {15m}";
          }
          {
            block = "temperature";
            collapsed = false;
            format = "{max}";
          }
          {
            block = "cpu";
            format = "{barchart} {frequency}";
          }
          {
            block = "memory";
            format_mem = "{mem_avail;M} {swap_free_percents}";
            clickable = false;
          }
          {
            block = "disk_space";
            format = "{icon} {available}";
          }
          {
            block = "networkmanager";
            on_click = "alacritty -e nmtui";
            ap_format = "{ssid} {strength}";
            device_format = "{icon}{ap}";
          }
          {
            block = "net";
            format = "{speed_down;K*B} {graph_down} {speed_up;K*B} {graph_up}";
          }
          { block = "sound"; }
          { block = "backlight"; }
          {
            block = "battery";
            format = "{percentage} {time} {power}";
          }
          {
            block = "keyboard_layout";
            driver = "sway";
            format = "{layout^2}";
          }
          {
            block = "time";
            format = "%a %F %T";
            interval = 1;
          }
        ];
      };
    };
  };
}
