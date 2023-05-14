{ pkgs, hyprland, ... }: {
  imports = [ ./bar.nix ];

  environment.sessionVariables.NIXOS_OZONE_WL = "1";
  security.pam.services.swaylock.enableGnomeKeyring = true;
  programs.dconf.enable = true;

  home-manager.users.freopen = {
    imports = [ hyprland.homeManagerModules.default ];
    home = {
      packages = with pkgs; [ xorg.xprop networkmanagerapplet ];
      pointerCursor = {
        package = pkgs.simp1e-cursors;
        name = "Simp1e-Adw-Dark";
        x11.enable = true;
        gtk.enable = true;
      };
    };
    programs = {
      foot.enable = true;
      swaylock = {
        enable = true;
        settings = {
          color = "#07260a";
          show-failed-attempts = true;
        };
      };
    };
    services = {
      blueman-applet.enable = true;
      swayidle = {
        enable = true;
        systemdTarget = "graphical-session.target";
        events = [{
          event = "before-sleep";
          command = "${pkgs.swaylock}/bin/swaylock";
        }];
        timeouts = [{
          timeout = 300;
          command = "${pkgs.swaylock}/bin/swaylock";
        }];
      };
      dunst.enable = true;
      udiskie = {
        enable = true;
        automount = true;
        notify = true;
      };
    };
    wayland.windowManager.hyprland = {
      enable = true;
      xwayland = {
        enable = true;
        hidpi = true;
      };
      recommendedEnvironment = true;
      extraConfig = ''
        exec-once = swaylock
        source = ${./general.conf}
        source = ${./binds.conf}
      '';
    };
    gtk = {
      enable = true;
      theme = {
        name = "Adwaita-dark";
        package = pkgs.gnome.gnome-themes-extra;
      };
      iconTheme = {
        name = "Adwaita";
        package = pkgs.gnome.adwaita-icon-theme;
      };
    };
  };
}
