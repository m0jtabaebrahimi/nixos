{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/packages
  ];

  # --- Boot Configuration ---
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # --- Network Configuration ---
  networking.hostName = "iic-pc";

  # --- Agenix Secrets ---
  modules.agenix.enable = true;

  # --- Secrets ---
  modules.secrets.pptpVpn = {
    enable = true;
    connectionName = "iic-vpn";
    chapSecretsFile = ../../secrets/ppp-chap-secrets.age;
    peersFile = ../../secrets/ppp-peers-iic-vpn.age;
  };
  modules.userSecrets.mojodev.enable = true;

  # --- Locale ---
  modules.locale.preset = "persian";

  # --- Hardware ---
  modules.hardware.bluetooth.enable = true;
  modules.hardware.virtualization.docker.enable = true;
  modules.hardware.virtualization.virtualbox.enable = true;

  # --- Services ---
  modules.services.ssh.enable = true;
  modules.services.ssh.maxAuthTries = 10;
  modules.services.vpn.pptp = {
    enable = true;
    connectionName = "iic-vpn";
  };
  modules.services.ntopng.enable = true;

  # --- User Configuration ---
  modules.users.mojodev.enable = true;
  modules.users.mojodev.extraGroups = [ "vboxusers" ];

  # --- Display Manager ---
  modules.displayManager.enable = true;
  modules.displayManager.autoLogin.enable = false;

  # --- Host-Specific Packages ---
  environment.systemPackages = with pkgs; [
    # Patch ppp package to fix hardcoded /bin/kill path in poff script
    (ppp.overrideAttrs (oldAttrs: {
      postInstall = (oldAttrs.postInstall or "") + ''
        substituteInPlace $out/bin/poff \
          --replace-fail '/bin/kill' '${coreutils}/bin/kill'
      '';
    }))
    pptp
    openfortivpn
    keepassxc
    sing-box
  ];

  system.stateVersion = "25.11";
}
