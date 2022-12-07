{ pkgs, ... }: {
  home-manager.users.freopen = {
    programs = {
      direnv = {
        enable = true;
        config.whitelist.prefix = [ "/home/freopen/Projects" ];
        nix-direnv.enable = true;
      };
      zsh.enable = true;
      vscode = {
        enable = true;
        package = pkgs.vscode.fhs;
      };
    };
  };
}
