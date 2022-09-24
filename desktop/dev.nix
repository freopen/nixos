{ pkgs, ... }:
{
  home-manager.users.freopen = {
    home = {
      packages = with pkgs; [
        vscode
        rnix-lsp
      ];
    };
    programs.home-manager.enable = true;
  };
}
