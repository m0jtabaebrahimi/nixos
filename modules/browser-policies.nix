{ config, pkgs, lib, ... }:

{
  # System-level browser policies for Brave
  environment.etc."brave/policies/managed/extensions.json".text = builtins.toJSON {
    ExtensionInstallForcelist = [
      "nngceckbapebfimnlniiiahkandclblb;https://clients2.google.com/service/update2/crx"
    ];
  };

  # Also create for chromium path as fallback
  environment.etc."chromium/policies/managed/extensions.json".text = builtins.toJSON {
    ExtensionInstallForcelist = [
      "nngceckbapebfimnlniiiahkandclblb;https://clients2.google.com/service/update2/crx"
    ];
  };
}
