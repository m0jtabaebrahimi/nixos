# Host-level secrets management via agenix
# Manages system secrets like VPN credentials

{ config, lib, ... }:

let
  cfg = config.modules.secrets;
in

{
  options.modules.secrets = {
    pptpVpn = {
      enable = lib.mkEnableOption "PPTP VPN secrets";

      connectionName = lib.mkOption {
        type = lib.types.str;
        example = "iic-vpn";
        description = "Name of the PPTP connection";
      };

      chapSecretsFile = lib.mkOption {
        type = lib.types.path;
        example = "../../secrets/ppp-chap-secrets.age";
        description = "Path to the encrypted chap-secrets file";
      };

      peersFile = lib.mkOption {
        type = lib.types.path;
        example = "../../secrets/ppp-peers-iic-vpn.age";
        description = "Path to the encrypted peers configuration file";
      };
    };

    wireguard = {
      enable = lib.mkEnableOption "WireGuard VPN secrets";
    };

    protonvpn = {
      enable = lib.mkEnableOption "ProtonVPN secrets";
    };
  };

  config = lib.mkMerge [
    # PPTP VPN credentials
    (lib.mkIf cfg.pptpVpn.enable {
      age.secrets."ppp-chap-secrets" = {
        file = cfg.pptpVpn.chapSecretsFile;
        path = "/etc/ppp/chap-secrets";
        mode = "600";
        owner = "root";
        group = "root";
      };

      age.secrets."ppp-peers-${cfg.pptpVpn.connectionName}" = {
        file = cfg.pptpVpn.peersFile;
        path = "/etc/ppp/peers/${cfg.pptpVpn.connectionName}";
        mode = "644";
        owner = "root";
        group = "root";
      };
    })

    # WireGuard private keys
    (lib.mkIf cfg.wireguard.enable {
      age.secrets."wireguard-private-key" = {
        file = ../../secrets/wireguard-private-key.age;
        path = "/etc/wireguard/private.key";
        mode = "600";
        owner = "root";
        group = "root";
      };
    })

    # ProtonVPN credentials
    (lib.mkIf cfg.protonvpn.enable {
      age.secrets."protonvpn-credentials" = {
        file = ../../secrets/protonvpn-credentials.age;
        path = "/root/.protonvpn/credentials";
        mode = "600";
        owner = "root";
        group = "root";
      };
    })
  ];
}
