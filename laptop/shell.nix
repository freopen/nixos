{ pkgs, ... }:
{
  users.users.freopen.shell = pkgs.zsh;
  # Needed for Zsh system packages completion
  environment.pathsToLink = ["/share/zsh"];
  home-manager.users.freopen = {
    programs = {
      zsh = {
        enable = true;
        enableAutosuggestions = true;
        enableSyntaxHighlighting = true;
      };
    };
  };
}
