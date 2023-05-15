{ ... }: {
  programs.steam = {
    enable = true;
    gamescopeSession.enable = true;
  };
  programs.gamescope = { capSysNice = true; };
}
