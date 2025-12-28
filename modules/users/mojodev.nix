# User configuration for mojodev
# Provides base user setup with configurable extra groups

{ config, lib, pkgs, ... }:

let
  cfg = config.modules.users.mojodev;
in

{
  options.modules.users.mojodev = {
    enable = lib.mkEnableOption "mojodev user configuration";

    extraGroups = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "Additional groups to add to the user beyond the base set";
      example = [ "docker" "vboxusers" ];
    };
  };

  config = lib.mkIf cfg.enable {
    users.users.mojodev = {
      isNormalUser = true;
      description = "Mojo Dev User";
      extraGroups = [
        "networkmanager"
        "wheel"
        "wireshark"
      ] ++ cfg.extraGroups;
      shell = pkgs.zsh;
    };

    # Enable zsh system-wide for the user
    programs.zsh.enable = true;
  };
}
