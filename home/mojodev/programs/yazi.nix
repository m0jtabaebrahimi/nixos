{ config, pkgs, ... }:

let
  # Fetch yazi official plugins repository
  yaziPlugins = pkgs.fetchFromGitHub {
    owner = "yazi-rs";
    repo = "plugins";
    rev = "main";
    hash = "sha256-G4Pqb8ct7om4UfihGr/6GoUn69HbzFVTxlulTeXZyEk=";
  };
in
{
  # Yazi file manager configuration

  programs.yazi = {
    enable = true;
    enableZshIntegration = true;

    # Yazi plugins - installed via Home Manager
    plugins = {
      git = "${yaziPlugins}/git.yazi";
      mount = "${yaziPlugins}/mount.yazi";
      mime-ext = "${yaziPlugins}/mime-ext.yazi";
    };

    settings = {
      mgr = {
        show_hidden = true;
        sort_by = "natural";
      };
    };
  };
}
