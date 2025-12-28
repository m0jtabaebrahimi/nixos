{ config, pkgs, ... }:

{
  # Common system packages shared across hosts
  environment.systemPackages = with pkgs; [
    # Base
    bat
    
    # --- Networking ---
    networkmanager
    curl
    wget
    tcpdump
    dnsutils
    wireshark

    # --- Terminals ---
    kitty
    alacritty
    tmux
    zellij

    # --- Browsers ---
    firefox
    brave
    tor-browser

    # --- Editors ---
    # neovim - Managed by Home Manager
    helix

    # System monitoring (btop instead of htop)
    btop

    # Image editing
    swayimg
    gimp

    # Messaging & Communication
    telegram-desktop
    remmina

    # Office suite
    libreoffice-fresh

    # --- Development Tools ---
    vscode.fhs
    git
    insomnia
    dbeaver-bin
    devenv
    direnv
    php83
    php83Packages.composer

    # --- File Management ---
    # yazi - Now managed via programs.yazi in home/mojodev/programs/yazi.nix
    fzf

    # Archive utilities
    unzip
    unrar

    # --- Wayland / Niri Ecosystem ---
    niri
    waybar
    wofi
    mako
    wl-clipboard
    grim
    slurp
    swaylock
    swayidle

    # --- Desktop Utilities ---
    # polkit_gnome
    libnotify

    # --- Multimedia ---
    ffmpeg
    vlc

    # --- Graphics / Gaming Support ---
    vkd3d
    vulkan-tools
    mesa
    mesa-demos
    bottles

    # AI stuffs
    ollama
    claude-code
    opencode
    
    # X11 utilities
    xeyes
        
    # --- Containerization ---
    docker
    docker-compose
    
  ];

  # Common programs configuration
  programs = {
    wireshark.enable = true;
    zsh.enable = true;
    dconf.enable = true;
    # Enable direnv with nix-direnv for automatic environment switching
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
  };

  # Trust devenv cache for faster builds
  nix.settings.trusted-substituters = [
    "https://devenv.cachix.org"
  ];
  nix.settings.trusted-public-keys = [
    "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
  ];

# Common fonts
  fonts = {
    fontconfig.enable = true;
    packages = with pkgs; [
      nerd-fonts.jetbrains-mono
      vazir-fonts
    ];
  };
}
