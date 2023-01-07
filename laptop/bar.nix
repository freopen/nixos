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
            block = "keyboard_layout";
            driver = "sway";
            format = "{layout^2}";
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
          { block = "memory"; }
          { block = "disk_space"; }
          {
            block = "net";
            format =
              "{ssid} {signal_strength} {speed_down;K*B} {graph_down} {speed_up;K*B} {graph_up}";
          }
          { block = "sound"; }
          { block = "backlight"; }
          {
            block = "battery";
            format = "{percentage} {time} {power}";
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
