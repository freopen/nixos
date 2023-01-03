{ pkgs, ... }: {
  fonts = {
    fonts = with pkgs;
      [ (nerdfonts.override { fonts = [ "SourceCodePro" ]; }) ];
    fontconfig.defaultFonts = { monospace = [ "Sauce Code Pro Nerd Font" ]; };
  };
}

