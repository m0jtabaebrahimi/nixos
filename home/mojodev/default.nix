{ config, pkgs, inputs, osConfig, ... }:

let
  # Determine VPN connection name based on host
  vpnConnectionName =
    if osConfig.networking.hostName == "iic-pc"
    then "iic-vpn"
    else "iic-vpn-ati";
in

{
  imports = [
    ./programs/common.nix
    ./programs/zsh.nix
    ./programs/vscode.nix
    ./programs/alacritty.nix
    ./programs/browsers.nix
    ./programs/thunderbird.nix
    ./programs/neovim.nix
    ./programs/rofi.nix
    ./programs/yazi.nix
    ./desktop/niri.nix
    ./desktop/waybar.nix
    ./desktop/noctalia.nix

    inputs.noctalia-shell.homeModules.default
  ];

  home.username = "mojodev";
  home.homeDirectory = "/home/mojodev";
  home.stateVersion = "24.11";

  home.packages = with pkgs; [ ];

  home.file = {
    "Pictures/wallpapers/nixos-wallpaper.png".source = ../../wallpapers/nixos-wallpaper.png;

    ".cache/noctalia/wallpapers.json".text = builtins.toJSON {
      defaultWallpaper = "${config.home.homeDirectory}/Pictures/wallpapers/nixos-wallpaper.png";
      wallpapers = {
        "DP-1" = "${config.home.homeDirectory}/Pictures/wallpapers/nixos-wallpaper.png";
      };
    };
  };

  home.sessionVariables = {
    WLR_RENDERER = "pixman";
    WLR_NO_HARDWARE_CURSORS = "1";
  };

  systemd.user.sessionVariables = {
    DISPLAY = ":0";
    ELECTRON_OZONE_PLATFORM_HINT = "auto";
  };

  programs.home-manager.enable = true;
}

