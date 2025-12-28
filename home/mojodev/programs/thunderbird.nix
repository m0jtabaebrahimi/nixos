{ config, pkgs, ... }:

{
  # Thunderbird email client configuration
  programs.thunderbird = {
    enable = true;
    profiles.default = {
      isDefault = true;
    };
  };
}
