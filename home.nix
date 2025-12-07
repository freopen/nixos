{ pkgs, lib, ... }:
{
  home = {
    username = "freopen";
    homeDirectory = "/home/freopen";
    stateVersion = "25.11";
    packages = with pkgs; [
      nerd-fonts.iosevka-term
      nixd
      nixfmt-rfc-style
      rustup
      sysz
    ];
    shell.enableZshIntegration = true;
    sessionVariables = {
      SSH_ASKPASS = "/usr/bin/ksshaskpass";
      SSH_ASKPASS_REQUIRE = "prefer";
    };
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
    zsh = {
      enable = true;
      autocd = true;
      autosuggestion = {
        enable = true;
        strategy = [
          "match_prev_cmd"
          "completion"
        ];
      };
      defaultKeymap = "viins";
      enableVteIntegration = true;
      history = {
        append = true;
        expireDuplicatesFirst = true;
        extended = true;
      };
      historySubstringSearch.enable = true;
      initContent = lib.mkOrder 550 ''
        # Add system completions to fpath
        fpath+=("/usr/share/zsh/site-functions")
        fpath+=("/usr/share/zsh/vendor-completions")
        fpath+=("/usr/share/zsh/$ZSH_VERSION/functions")
      '';
      syntaxHighlighting = {
        enable = true;
      };
    };
    starship = {
      enable = true;
      enableZshIntegration = true;
    };
    fzf.enable = true;
  };
  nixpkgs.config.allowUnfree = true;
  services.home-manager = {
    autoExpire = {
      enable = true;
      frequency = "weekly";
      store.cleanup = true;
    };
    autoUpgrade = {
      enable = true;
      frequency = "weekly";
      useFlake = true;
      flakeDir = "/home/freopen/Documents/nixos";
    };
  };
  news.display = "silent";
}
