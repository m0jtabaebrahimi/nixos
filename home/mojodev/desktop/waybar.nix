{ config, pkgs, ... }:

{
  # Waybar status bar configuration
  
  programs.waybar = {
    enable = false;
    
    # Basic configuration - can be expanded with custom styling and modules
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 30;
        
        modules-left = [ "niri/workspaces" "niri/window" ];
        modules-center = [ "clock" ];
        modules-right = [ "pulseaudio" "network" "battery" "tray" ];
        
        "niri/workspaces" = {
          format = "{name}";
        };
        
        "niri/window" = {
          max-length = 50;
        };
        
        clock = {
          format = "{:%H:%M}";
          format-alt = "{:%Y-%m-%d}";
        };
        
        battery = {
          format = "{capacity}% {icon}";
          format-icons = [ "" "" "" "" "" ];
        };
        
        network = {
          format-wifi = "{essid} ";
          format-ethernet = "{ipaddr}/{cidr} ";
          format-disconnected = "Disconnected ⚠";
        };
        
        pulseaudio = {
          format = "{volume}% {icon}";
          format-muted = "";
          format-icons = {
            default = [ "" "" "" ];
          };
        };
      };
    };
    
    # Basic styling - can be customized further
    style = ''
      * {
        font-family: "JetBrains Mono", monospace;
        font-size: 13px;
      }
      
      window#waybar {
        background-color: rgba(43, 48, 59, 0.9);
        color: #ffffff;
      }
      
      #workspaces button {
        padding: 0 5px;
        background-color: transparent;
        color: #ffffff;
      }
      
      #workspaces button.active {
        background-color: rgba(255, 255, 255, 0.2);
      }
      
      #clock, #battery, #network, #pulseaudio, #tray {
        padding: 0 10px;
      }
    '';
  };
}
