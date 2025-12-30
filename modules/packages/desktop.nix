# Desktop GUI applications
# Browsers, office suites, multimedia, and communication tools

{ config, pkgs, inputs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Browsers
    firefox
    brave
    tor-browser

    # Terminals
    kitty
    alacritty
    tmux
    zellij

    # Multimedia
    ffmpeg
    vlc
    swayimg
    gimp

    # Communication
    telegram-desktop
    remmina

    # Office suite
    libreoffice-fresh

    # Graphics and gaming support
    vkd3d
    vulkan-tools
    mesa
    mesa-demos
    bottles

    # X11 utilities (for compatibility)
    xeyes

    # Desktop utilities
    libnotify
  ];

  # Fonts configuration
  fonts = {
    fontconfig.enable = true;
    packages = with pkgs; [
      nerd-fonts.jetbrains-mono
      vazir-fonts
    ];
  };
}
