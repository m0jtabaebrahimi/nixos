{ config, pkgs, lib, ... }:

{
  # Zsh shell configuration
  
  # Install powerlevel10k theme
  home.packages = with pkgs; [
    zsh-powerlevel10k
  ];

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "sudo" "direnv" ];
      # theme = "robbyrussell"; # Default fallback, P10K loaded below
    };

    plugins = [
      {
        name = "powerlevel10k";
        src = pkgs.zsh-powerlevel10k;
        file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      }
    ];

    shellAliases = {
      # VirtualBox with XWayland support
      virtualbox = "QT_QPA_PLATFORM=xcb virtualbox";
      VirtualBox = "QT_QPA_PLATFORM=xcb VirtualBox";
    };

    initContent = lib.mkMerge [
      # Runs BEFORE plugins are loaded
      (lib.mkBefore ''
        # Disable P10K wizard (must be set before theme loads)
        POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD=true
      '')
      # Runs AFTER plugins are loaded
      ''
        # Source Powerlevel10k config
        [[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

        # Source encrypted secrets env file
        [[ -f ~/.secrets.env ]] && source ~/.secrets.env
      ''
    ];
  };

  # Deploy default p10k config
  home.file.".p10k.zsh".source = ./p10k.zsh;
}
