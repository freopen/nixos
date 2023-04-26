{ pkgs, ... }: {
  environment = {
    systemPackages = with pkgs; [
      bat
      broot
      curl
      fd
      fzf
      git
      glances
      jc
      jq
      navi
      nix-output-monitor
      pciutils
      sysz
      thefuck
      zsh-completions
    ];
    sessionVariables = { MANPAGER = "sh -c 'col -bx | bat -l man -p'"; };
  };
  users.defaultUserShell = pkgs.zsh;
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    vimAlias = true;
  };
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
    promptInit = ''
      source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
      source ${./.p10k.zsh}
    '';
    interactiveShellInit = ''
      ZSH_ALIAS_FINDER_AUTOMATIC=true
      FZF_DEFAULT_OPTS="--preview 'bat --color=always {}'"
    '';
    ohMyZsh = {
      enable = true;
      plugins = [
        "alias-finder"
        "command-not-found"
        "common-aliases"
        "git"
        "fd"
        "fzf"
        "systemd"
        "thefuck"
        "vscode"
      ];
    };
  };
}
