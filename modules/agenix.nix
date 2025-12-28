# Agenix secrets management module
# Provides encrypted secrets management for NixOS configurations

{ config, lib, pkgs, agenix, ... }:

with lib;

let
  cfg = config.modules.agenix;
in {
  options.modules.agenix = {
    enable = mkEnableOption "agenix secrets management";

    secretsDirectory = mkOption {
      type = types.str;
      default = ../../secrets; # Corrected: one level up from modules/
      description = "Directory containing encrypted secrets";
    };
  };

  config = mkIf cfg.enable {
    # Install agenix package for secret management
    environment.systemPackages = with pkgs; [
      agenix.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];

    # Enable age encryption for secrets
    age.identityPaths = [
      "/etc/ssh/ssh_host_ed25519_key"
      "${config.users.users.mojodev.home}/.ssh/id_ed25519"
    ];

    # Default secrets configuration
    # Add your secrets here using:
    # age.secrets.secret-name = {
    #   file = ../secrets/secret-name.age;
    #   mode = "600";
    #   owner = "user";
    #   group = "group";
    # };
    # Note: Secrets should be defined in host-specific configurations to avoid path resolution issues
  };
}