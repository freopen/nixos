{ ... }: {
  programs.steam = {
    enable = true;
    gamescopeSession = { enable = true; };
  };
  programs.gamescope = { capSysNice = true; };
  home-manager.users.freopen.programs.mangohud = {
    enable = true;
    settings = {
      toggle_hud = "F12";
      font_size = 12;
      hud_compact = true;
      hud_no_margin = true;
      battery = true;
      gamepad_battery = true;
      cpu_power = true;
      cpu_temp = true;
      gpu_power = true;
      gpu_temp = true;
      ram = true;
      vram = true;
      resolution = true;
    };
  };
}
