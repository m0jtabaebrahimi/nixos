{ config, pkgs, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/packages
  ];

  # --- Boot Configuration ---
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # --- Network Configuration ---
  networking.hostName = "laptop";

  # --- Hardware ---
  modules.hardware.bluetooth.enable = true;
  modules.hardware.virtualization.docker.enable = true;

  # --- Locale ---
  modules.locale.preset = "utc";

  # --- User Configuration ---
  modules.users.mojodev.enable = true;
  # No extra groups needed for laptop

  # --- Secrets ---
  modules.agenix.enable = true;
  modules.secrets.pptpVpn = {
    enable = true;
    connectionName = "iic-vpn-ati";
    chapSecretsFile = ../../secrets/ppp-chap-secrets-iic-ati.age;
    peersFile = ../../secrets/ppp-peers-iic-vpn-ati.age;
  };
  modules.userSecrets.mojodev.enable = true;

  # --- Services ---
  modules.services.vpn.pptp = {
    enable = true;
    connectionName = "iic-vpn-ati";
  };
  modules.services.ntopng.enable = true;

  # --- Display Manager ---
  modules.displayManager.enable = true;
  # No auto-login for laptop (more secure for portable device)

  system.stateVersion = "25.11";
}
