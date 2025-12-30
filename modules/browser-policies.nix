{ config, pkgs, lib, ... }:

let
  # Bitwarden extension for Chromium-based browsers
  bitwardenExtension = "nngceckbapebfimnlniiiahkandclblb;https://clients2.google.com/service/update2/crx";

  extensionPolicy = builtins.toJSON {
    ExtensionInstallForcelist = [ bitwardenExtension ];
  };
in
{
  # System-level browser policies for Chromium-based browsers
  environment.etc = {
    # Brave
    "brave/policies/managed/extensions.json".text = extensionPolicy;

    # Chromium
    "chromium/policies/managed/extensions.json".text = extensionPolicy;

    # Google Chrome
    "opt/chrome/policies/managed/extensions.json".text = extensionPolicy;
  };
}
