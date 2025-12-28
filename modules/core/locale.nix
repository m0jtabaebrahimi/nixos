# Locale and timezone configuration
# Provides preset configurations for common locale/timezone combinations

{ config, lib, ... }:

let
  cfg = config.modules.locale;

  # Preset configurations for common use cases
  presets = {
    persian = {
      timezone = "Asia/Tehran";
      extraLocale = "en_US.UTF-8";  # fa_IR.UTF-8 is not supported by glibc
    };
    utc = {
      timezone = "UTC";
      extraLocale = "en_US.UTF-8";
    };
  };
in

{
  options.modules.locale = {
    preset = lib.mkOption {
      type = lib.types.enum [ "persian" "utc" "custom" ];
      default = "utc";
      description = "Preset locale and timezone configuration";
    };

    timezone = lib.mkOption {
      type = lib.types.str;
      default = presets.${cfg.preset}.timezone or "UTC";
      description = "System timezone (used when preset is 'custom')";
    };
  };

  config = {
    # System timezone
    time.timeZone = if cfg.preset != "custom"
      then presets.${cfg.preset}.timezone
      else cfg.timezone;

    # Locale settings (UI always in English for consistency)
    i18n.defaultLocale = "en_US.UTF-8";

    # Additional locale settings
    i18n.extraLocaleSettings = {
      LC_ADDRESS = presets.${cfg.preset}.extraLocale or "en_US.UTF-8";
      LC_IDENTIFICATION = presets.${cfg.preset}.extraLocale or "en_US.UTF-8";
      LC_MEASUREMENT = presets.${cfg.preset}.extraLocale or "en_US.UTF-8";
      LC_MONETARY = presets.${cfg.preset}.extraLocale or "en_US.UTF-8";
      LC_NAME = presets.${cfg.preset}.extraLocale or "en_US.UTF-8";
      LC_NUMERIC = presets.${cfg.preset}.extraLocale or "en_US.UTF-8";
      LC_PAPER = presets.${cfg.preset}.extraLocale or "en_US.UTF-8";
      LC_TELEPHONE = presets.${cfg.preset}.extraLocale or "en_US.UTF-8";
      LC_TIME = presets.${cfg.preset}.extraLocale or "en_US.UTF-8";
    };
  };
}
