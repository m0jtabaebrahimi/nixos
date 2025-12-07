{ pkgs, lib, ... }:

{
  imports = [
    ./hardware-specifics.nix
  ];

  # Allow unfree packages (required for VS Code, Steam, etc.)
  nixpkgs.config.allowUnfree = true;

  # --- Network Configuration ---
  networking.hostName = "mojtaba-nixpc";
  networking.networkmanager.enable = true;

  programs = {
    niri.enable = true;
    wireshark.enable = true;

    #steam = {
    #  enable = true;
    #  remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    #  dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    #  localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
    #};

    #gamemode.enable = true;
    zsh.enable = true;
  };

  users.users.nixos.shell = pkgs.zsh;

  time.timeZone = "Asia/Tehran";
  i18n.defaultLocale = "en_US.UTF-8";
  #i18n.defaultLocale = "fa_IR.UTF-8";

  # --- Graphics & Display ---
  # hardware.graphics.enable = true; # Moved to hardware-specifics.nix

  # --- Essential Packages ---
  environment.systemPackages = with pkgs; [
    kitty 
    alacritty
    brave
    firefox
    neovim
    vscode.fhs
    git
    wofi
    waybar
    mako
    wl-clipboard
    grim
    slurp
    swaylock
    swayidle
    polkit_gnome
    libnotify
    fzf
    ffmpeg
    vlc
    curl
    yazi
  ];

  # --- Home Manager Configuration for Niri ---
  home-manager.users.nixos = { pkgs, ... }: {
    home.stateVersion = "24.05";
    xdg.configFile."niri/config.kdl".text = ''
      input {
        keyboard {
          xkb {
            layout "us"
          }
        }
        touchpad {
          tap
        }
      }

      spawn-at-startup "waybar"
      spawn-at-startup "mako"

      binds {
        Mod+Shift+E { quit; }
        Mod+Q { close-window; }

        Mod+Return { spawn "alacritty"; }
        Mod+T { spawn "alacritty"; }
        Mod+D { spawn "wofi" "--show" "drun"; }
        Mod+E { spawn "alacritty" "-e" "yazi"; }

        Mod+Left  { focus-column-left; }
        Mod+Right { focus-column-right; }
        Mod+WheelScrollDown { focus-column-right; }
        Mod+WheelScrollUp   { focus-column-left; }

        Mod+Ctrl+Left  { move-column-left; }
        Mod+Ctrl+Right { move-column-right; }

        Mod+Home { focus-column-first; }
        Mod+End  { focus-column-last; }
        
        Mod+F { maximize-column; }
        Mod+Shift+F { fullscreen-window; }
        Mod+C { center-column; }

        Print { screenshot; }
        Ctrl+Print { screenshot-screen; }
        Alt+Print { screenshot-window; }
      }
    '';
  };

  fonts = {
    fontconfig.enable = true;
    packages = with pkgs; [
      nerd-fonts.jetbrains-mono
    ];
  };

  security.sudo.wheelNeedsPassword = false;
}