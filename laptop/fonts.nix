{ pkgs, ... }: {
  fonts = {
    fonts = with pkgs; [
      (nerdfonts.override { fonts = [ "SourceCodePro" ]; })
      noto-fonts
      noto-fonts-emoji
    ];
    fontconfig.defaultFonts = {
      monospace = [ "Sauce Code Pro Nerd Font" ];
      serif = [ "Noto Serif" ];
      sansSerif = [ "Noto Sans" ];
      emoji = [ "Noto Color Emoji" ];
    };
  };
}

