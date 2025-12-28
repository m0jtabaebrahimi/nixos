{ config, pkgs, ... }:

{
  # Firefox configuration
  programs.firefox = {
    enable = true;
    profiles.default = {
      id = 0;
      name = "default";
      isDefault = true;

      extensions.packages = with pkgs.nur.repos.rycee.firefox-addons; [
        bitwarden
        ublock-origin
      ];

      settings = {
        # Privacy settings
        "browser.startup.homepage" = "about:home";
        "privacy.donottrackheader.enabled" = true;
      };
    };
  };

  # Note: Brave/Chromium extension policies are configured at system level
  # in modules/browser-policies.nix
}
