{ pkgs, config, hyprland, ... }:
let
  hyprland-pkg =
    config.home-manager.users.freopen.wayland.windowManager.hyprland.package;
in {
  imports = [ ./bar.nix ];

  environment.sessionVariables.NIXOS_OZONE_WL = "1";
  security.pam.services.swaylock.enableGnomeKeyring = true;
  programs.dconf.enable = true;

  home-manager.users.freopen = {
    imports = [ hyprland.homeManagerModules.default ];
    home = {
      packages = with pkgs; [
        grim
        networkmanagerapplet
        slurp
        wl-clipboard
        xdg-desktop-portal
        xdg-desktop-portal-hyprland
        xorg.xprop
      ];
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
          command = "${pkgs.swaylock}/bin/swaylock -f";
        }];
        timeouts = [
          {
            timeout = 290;
            command = "${hyprland-pkg}/bin/hyprctl dispatch dpms off";
            resumeCommand = "${hyprland-pkg}/bin/hyprctl dispatch dpms on";
          }
          {
            timeout = 300;
            command = "${pkgs.swaylock}/bin/swaylock -f";
          }
        ];
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
