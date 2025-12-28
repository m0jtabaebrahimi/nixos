# User-level secrets management via agenix
# Manages mojodev user secrets (environment variables, SSH keys, API tokens)

{ config, lib, ... }:

let
  cfg = config.modules.userSecrets.mojodev;
in

{
  options.modules.userSecrets.mojodev = {
    enable = lib.mkEnableOption "mojodev user secrets";

    envFile = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable environment variables file (.secrets.env)";
    };

    sshKeys = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable private SSH keys";
    };

    apiTokens = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable API tokens file";
    };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    # Environment variables file (enabled by default when module is enabled)
    (lib.mkIf cfg.envFile {
      age.secrets."mojodev-secrets" = {
        file = ../../secrets/mojodev-secrets.age;
        path = "/home/mojodev/.secrets.env";
        mode = "600";
        owner = "mojodev";
        group = "users";
      };
    })

    # SSH private keys (opt-in)
    (lib.mkIf cfg.sshKeys {
      age.secrets."mojodev-ssh-keys" = {
        file = ../../secrets/mojodev-ssh-keys.age;
        path = "/home/mojodev/.ssh/id_ed25519_decrypted";
        mode = "600";
        owner = "mojodev";
        group = "users";
      };
    })

    # API tokens (opt-in)
    (lib.mkIf cfg.apiTokens {
      age.secrets."mojodev-api-tokens" = {
        file = ../../secrets/mojodev-api-tokens.age;
        path = "/home/mojodev/.config/tokens.env";
        mode = "600";
        owner = "mojodev";
        group = "users";
      };
    })
  ]);
}
