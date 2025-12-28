{ config, pkgs, ... }:

{
  # Common tools and utilities configuration

  # Enable and configure Git
  programs.git = {
    enable = true;
    settings = {
      user.name = "mojodev";
      user.email = "mojodev@localhost";
    };
  };

  # Enable BTOP system monitor
  programs.btop = {
    enable = true;
    settings = {
      color_theme = "Default";
      theme_background = false;
    };
  };

  programs.obs-studio = {
    enable = true;

    # optional Nvidia hardware acceleration
    package = (
      pkgs.obs-studio.override {
        cudaSupport = true;
      }
    );

    plugins = with pkgs.obs-studio-plugins; [
      wlrobs
      obs-backgroundremoval
      obs-pipewire-audio-capture
      obs-vaapi #optional AMD hardware acceleration
      obs-gstreamer
      obs-vkcapture
    ];
  };

  # Install common CLI tools
  home.packages = with pkgs; [
    hello
  ];
}
