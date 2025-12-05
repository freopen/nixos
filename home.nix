{ pkgs, ... }:
{
  home = {
    username = "freopen";
    homeDirectory = "/home/freopen";
    stateVersion = "25.11";
    packages = with pkgs; [
      nixd
      nixfmt-rfc-style
      rustup
    ];
  };

  programs = {
    home-manager.enable = true;
    vscode.enable = true;
    git = {
      enable = true;
      settings = {
        user.name = "Aleksei Zolotov";
        user.email = "freopen@freopen.org";
      };
    };
  };
  nixpkgs.config.allowUnfree = true;
  news.display = "silent";
}
