{ config, pkgs, osConfig, ... }:

let
  # Determine VPN connection name based on host
  vpnConnectionName =
    if osConfig.networking.hostName == "iic-pc"
    then "iic-vpn"
    else "iic-vpn-ati";
in

{
  # Noctalia Shell - Custom shell/bar interface
  programs.noctalia-shell = {
    enable = true;
    settings = {
      bar = {
        widgets = {
          left = [
            {
              id = "CustomButton";
              icon = "rocket";
              leftClickExec = "qs -c noctalia-shell ipc call launcher toggle";
            }
            {
              id = "Clock";
              usePrimaryColor = false;
            }
            {
              id = "SystemMonitor";
            }
            {
              id = "ActiveWindow";
            }
            {
              id = "MediaMini";
            }
          ];
          center = [
            {
              id = "Workspace";
            }
          ];
          right = [
            {
              id = "CustomButton";
              icon = "keyboard";
              textCommand = "${pkgs.writeShellScriptBin "get-niri-layout" ''
                # Get the row with the asterisk (active layout) using fixed-string grep
                raw=$(${pkgs.niri}/bin/niri msg keyboard-layouts | grep -F '*')

                # Convert to lowercase to be safe
                raw_lower=$(echo "$raw" | tr '[:upper:]' '[:lower:]')

                if [[ "$raw_lower" == *"us"* ]] || [[ "$raw_lower" == *"english"* ]]; then
                  echo "EN"
                elif [[ "$raw_lower" == *"ir"* ]] || [[ "$raw_lower" == *"persian"* ]]; then
                  echo "FA"
                else
                  # Fallback: try to extract whatever is inside ( )
                  extracted=$(echo "$raw" | sed -n 's/.*(\(..\)).*/\1/p')
                  if [ -n "$extracted" ]; then
                     echo "''${extracted^^}"
                  else
                     # Last resort: just take the first 2 letters of the layout name after the asterisk
                     # raw format: "* LayoutName ..." -> cut asterisk and space (c3-4)
                     name=$(echo "$raw" | cut -c 3-4)
                     echo "''${name^^}"
                  fi
                fi
              ''}/bin/get-niri-layout";
              textIntervalMs = 1000;
              leftClickExec = "niri msg action switch-layout next";
              tooltip = "Switch Keyboard Layout";
            }
            {
              id = "WiFi";
            }
            {
              id = "Bluetooth";
            }
            {
              id = "CustomButton";
              icon = "lock";
              textCommand = "${pkgs.writeShellScriptBin "check-vpn-status" ''
                if [ -d /sys/class/net/ppp0 ]; then
                  echo "VPN: ON"
                else
                  echo "VPN: OFF"
                fi
              ''}/bin/check-vpn-status";
              textIntervalMs = 2000;
              leftClickExec = "${pkgs.writeShellScriptBin "toggle-vpn" ''
                 if [ -d /sys/class/net/ppp0 ]; then
                   /run/wrappers/bin/sudo /run/current-system/sw/bin/poff ${vpnConnectionName}
                 else
                   /run/wrappers/bin/sudo /run/current-system/sw/bin/pon ${vpnConnectionName}
                 fi
              ''}/bin/toggle-vpn";
              tooltip = "Toggle IIC VPN";
            }
            # {
            #   id = "ScreenRecorder";
            # }
            {
              id = "Tray";
            }
            {
              id = "NotificationHistory";
            }
            # {
            #   id = "Battery";
            # }
            {
              id = "Volume";
            }
            {
              id = "Brightness";
            }
            {
              id = "ControlCenter";
              useDistroLogo = true;
            }
            {
              id = "Wallpapers";
            }
          ];
        };
      };
      notifications = {
        enableKeyboardLayoutToast = true;
      };
    };
  };
}
