{ pkgs, ... }:
{
  home-manager.users.freopen = {
    home = {
      packages = with pkgs; [
        vscode
        rnix-lsp
        rustc
        cargo
      ];
    };
  };
}
