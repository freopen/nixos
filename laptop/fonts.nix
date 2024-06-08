{ pkgs, ... }: {
  fonts = {
    packages = with pkgs; [
      (nerdfonts.override { fonts = [ "IosevkaTerm" ]; })
      (iosevka-bin.override { variant = "Aile"; })
      (iosevka-bin.override { variant = "Etoile"; })
      noto-fonts
      noto-fonts-emoji
    ];
    fontconfig = {
      defaultFonts = {
        monospace = [ "IosevkaTerm Nerd Font" ];
        serif = [ "Iosevka Etoile" "Noto Serif" ];
        sansSerif = [ "Iosevka Aile" "Noto Sans" ];
        emoji = [ "Noto Color Emoji" ];
      };
      subpixel.rgba = "rgb";
      hinting.style = "full";
    };
  };
}
