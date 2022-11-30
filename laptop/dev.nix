{ pkgs, ... }: {
  home-manager.users.freopen = {
    home = { packages = with pkgs; [ vscode ]; };
    programs = {
      direnv = {
        enable = true;
        config.whitelist.prefix = [ "/home/freopen/Projects" ];
        nix-direnv.enable = true;
      };
      zsh.enable = true;
    };
  };
}
