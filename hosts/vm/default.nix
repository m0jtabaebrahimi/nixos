{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/packages
  ];

  # --- Boot Configuration ---
  # Using GRUB for VirtualBox VM (Legacy/Hybrid BIOS)
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = true;

  # --- Network Configuration ---
  networking.hostName = "vm";
  networking.networkmanager = {
    enable = true;
    plugins = with pkgs; [ networkmanager-openvpn ];
  };

  # --- Locale ---
  modules.locale.preset = "persian";

  # --- Hardware ---
  modules.hardware.bluetooth.enable = true;
  modules.hardware.virtualization.virtualbox.enable = true;
  modules.hardware.graphics.gaming.enable = true;

  # --- Services ---
  modules.services.ssh.enable = true;
  modules.services.ssh.maxAuthTries = 10;
  modules.services.vpn.pptp = {
    enable = true;
    connectionName = "iic-vpn-ati";
  };
  modules.services.ntopng.enable = true;

  # --- User Configuration ---
  modules.users.mojodev.enable = true;
  modules.users.mojodev.extraGroups = [ "vboxusers" "docker" ];

  # --- Secrets ---
  modules.agenix.enable = true;
  modules.secrets.pptpVpn = {
    enable = true;
    connectionName = "iic-vpn-ati";
    chapSecretsFile = ../../secrets/ppp-chap-secrets-iic-ati.age;
    peersFile = ../../secrets/ppp-peers-iic-vpn-ati.age;
  };
  modules.userSecrets.mojodev.enable = true;

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
    # VPN
    protonvpn-gui
    openvpn
    openfortivpn

    # Torrenting
    qbittorrent

    # Hardware management
    solaar

    # Specialized applications
    ledger-live-desktop
    kicad

    # Other
    blanket
  ];

  system.stateVersion = "25.11";
}
