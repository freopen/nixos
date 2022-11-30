{ pkgs, ... }: {
  environment = {
    systemPackages = with pkgs; [
      vim
      curl
      git
      bat
      jaq
      glances
      navi
      broot
      fd
      sysz
      zsh-completions
    ];
  };
  users.defaultUserShell = pkgs.zsh;
  programs.zsh = {
    enable = true;
    autosuggestions = {
      enable = true;
      strategy = [ "match_prev_cmd" "history" "completion" ];
    };
    syntaxHighlighting = {
      enable = true;
      highlighters = [ "main" "brackets" ];
    };
    enableBashCompletion = true;
  };
  programs.starship = {
    enable = true;
    settings = {
      directory.truncate_to_repo = false;
      time.disabled = false;
      status.disabled = false;
    };
  };
}
