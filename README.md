# NixOS Configuration

My modular, Flake-based NixOS configuration managing multiple machines with Home Manager integration.

## Hosts

| Host | Description | Display Manager | Window Manager |
|------|-------------|-----------------|----------------|
| `iic-pc` | Desktop PC with PPTP VPN, proxy configuration | SDDM | Niri |
| `laptop` | Basic laptop configuration | SDDM | Niri |
| `vm` | VirtualBox VM with gaming support | SDDM | Niri |

## Architecture

This configuration follows the **DRY (Don't Repeat Yourself)** principle with a highly modular structure:

```
┌─────────────────────────────────────────────────────────────┐
│                        flake.nix                            │
│         lib/mkHost.nix creates configurations               │
└─────────────────────────────────────────────────────────────┘
                              │
          ┌───────────────────┼───────────────────┐
          ▼                   ▼                   ▼
    ┌──────────┐        ┌──────────┐        ┌──────────┐
    │  laptop  │        │  iic-pc  │        │    vm    │
    └──────────┘        └──────────┘        └──────────┘
          │                   │                   │
          └───────────────────┼───────────────────┘
                              ▼
              ┌───────────────────────────────┐
              │    Modular Architecture       │
              │  • core/       (foundation)   │
              │  • hardware/   (BT, audio)    │
              │  • services/   (SSH, VPN)     │
              │  • users/      (mojodev)      │
              │  • secrets/    (agenix)       │
              │  • packages/   (organized)    │
              │  • profiles/   (composable)   │
              └───────────────────────────────┘
```

## Directory Structure

```
.
├── flake.nix                       # Entry point
├── lib/                            # Custom Nix functions
│   ├── default.nix                 # Exports all functions
│   ├── mkHost.nix                  # Host builder
│   └── helpers.nix                 # Utility functions
│
├── overlays/                       # Nixpkgs overlays
│   └── default.nix                 # NUR overlay
│
├── modules/                        # NixOS modules (system-level)
│   ├── core/                       # Essential configuration
│   │   ├── nix.nix                 # Nix settings, flakes
│   │   ├── locale.nix              # Locale with presets
│   │   ├── networking.nix          # NetworkManager
│   │   └── security.nix            # Sudo, polkit
│   │
│   ├── hardware/                   # Hardware enablement
│   │   ├── bluetooth.nix           # Bluetooth + blueman
│   │   ├── audio.nix               # PipeWire
│   │   ├── graphics/
│   │   │   └── gaming.nix          # Steam, GameMode
│   │   └── virtualization/
│   │       ├── docker.nix          # Docker rootless
│   │       └── virtualbox.nix      # VBox host/guest
│   │
│   ├── services/                   # System services
│   │   ├── ssh.nix                 # OpenSSH server
│   │   ├── vpn/
│   │   │   └── pptp.nix            # PPTP VPN
│   │   └── proxy.nix               # HTTP/SOCKS proxy
│   │
│   ├── desktop/                    # Desktop environment
│   │   ├── display-manager.nix     # SDDM (legacy)
│   │   └── fonts.nix               # System fonts
│   │
│   ├── users/                      # User management
│   │   ├── mojodev.nix             # User definition
│   │   └── secrets.nix             # User secrets
│   │
│   ├── secrets/                    # Host-level secrets
│   │   └── host-secrets.nix        # VPN credentials, etc.
│   │
│   ├── packages/                   # System packages
│   │   ├── base.nix                # CLI essentials
│   │   ├── development.nix         # Dev tools
│   │   ├── desktop.nix             # GUI apps
│   │   └── wayland.nix             # Niri ecosystem
│   │
│   └── profiles/                   # Composable profiles
│       ├── desktop.nix             # Full desktop
│       └── development.nix         # Dev workstation
│
├── home/                           # Home Manager configs
│   ├── mojodev/
│   │   ├── default.nix             # Main user config
│   │   ├── programs/               # Program configs (flat)
│   │   │   ├── zsh.nix
│   │   │   ├── neovim.nix
│   │   │   ├── vscode.nix
│   │   │   ├── alacritty.nix
│   │   │   └── ...
│   │   └── desktop/                # Desktop environment
│   │       ├── niri.nix            # Niri WM config
│   │       ├── waybar.nix
│   │       └── noctalia.nix
│   └── shared/                     # Shared HM modules
│       └── secrets.nix             # Secrets sourcing
│
├── hosts/                          # Machine-specific configs
│   ├── iic-pc/
│   │   ├── default.nix             # ~40 lines
│   │   └── hardware-configuration.nix
│   ├── laptop/
│   │   ├── default.nix             # ~35 lines
│   │   └── hardware-configuration.nix
│   └── vm/
│       ├── default.nix             # ~45 lines
│       └── hardware-configuration.nix
│
├── secrets/                        # Agenix encrypted secrets
│   ├── secrets.nix                 # Public key mappings
│   ├── ppp-chap-secrets.age
│   ├── ppp-peers-iic-vpn.age
│   └── mojodev-secrets.age
│
└── templates/                      # Dev environment templates
    ├── laravel-php84/
    └── legacy-php74/
```

## Module System

### Core Modules (Always Enabled)

Automatically applied to all hosts:
- **`modules.core.nix`** - Nix settings, flakes, unfree packages
- **`modules.core.locale`** - Locale with timezone presets
- **`modules.core.networking`** - NetworkManager base
- **`modules.core.security`** - Passwordless sudo for wheel

### Hardware Modules

```nix
# Bluetooth
modules.hardware.bluetooth.enable = true;
modules.hardware.bluetooth.powerOnBoot = true;  # default

# Audio (PipeWire)
modules.hardware.audio.enable = true;

# Gaming (Steam + GameMode + Gamescope)
modules.hardware.graphics.gaming.enable = true;

# Virtualization
modules.hardware.virtualization.docker.enable = true;
modules.hardware.virtualization.virtualbox.enable = true;
```

### Service Modules

```nix
# SSH
modules.services.ssh.enable = true;
modules.services.ssh.maxAuthTries = 10;

# Proxy
modules.services.proxy.enable = true;
modules.services.proxy.host = "192.0.2.100";
modules.services.proxy.port = 8080;

# PPTP VPN
modules.services.vpn.pptp.enable = true;
modules.services.vpn.pptp.allowPasswordlessSudo = true;  # default
```

### User & Secrets Modules

```nix
# User
modules.users.mojodev.enable = true;
modules.users.mojodev.extraGroups = [ "vboxusers" "docker" ];

# User secrets
modules.userSecrets.mojodev.enable = true;
modules.userSecrets.mojodev.sshKeys = true;     # optional
modules.userSecrets.mojodev.apiTokens = true;   # optional

# Host secrets
modules.secrets.pptpVpn.enable = true;
```

### Locale Presets

```nix
# UTC (default)
modules.locale.preset = "utc";

# Persian (Asia/Tehran + fa_IR)
modules.locale.preset = "persian";

# Custom
modules.locale.preset = "custom";
modules.locale.timezone = "Europe/London";
```

## Build Instructions

```bash
# Build without switching (for testing)
sudo nixos-rebuild build --flake .#<host>

# Build and switch to configuration
sudo nixos-rebuild switch --flake .#<host>
```

### Per-Host Commands

```bash
# iic-pc
sudo nixos-rebuild switch --flake .#iic-pc

# laptop
sudo nixos-rebuild switch --flake .#laptop

# vm
sudo nixos-rebuild switch --flake .#vm
```

## Niri Window Manager

```bash
# Validate configuration
niri validate

# Reload configuration (after changes to desktop/niri.nix)
niri msg action load-config-file

# Switch keyboard layout
# Mod+Space       - Next layout
# Mod+Shift+Space - Previous layout
```

## VPN Configuration

### iic-pc (PPTP VPN)

```bash
# Connect to VPN
sudo pon iic-vpn

# Disconnect from VPN
sudo poff iic-vpn
```

**Configuration managed with agenix:**
```bash
# Edit VPN credentials
agenix -e ppp-chap-secrets.age

# Edit VPN peer configuration
agenix -e ppp-peers-iic-vpn.age
```

### vm (ProtonVPN)

```bash
# Launch ProtonVPN GUI
protonvpn-gui
```

## Development Environment (Devenv)

This configuration includes [devenv](https://devenv.sh/) for per-project development environments with automatic PHP version switching.

### Quick Start

```bash
# Create a new Laravel 12.x project
mkdir my-project && cd my-project
cp -r ~/nixos/templates/laravel-php84/* .
direnv allow

# Install Laravel
composer create-project laravel/laravel .

# Start services
devenv up
```

### Available Templates

- **`templates/laravel-php84/`** - PHP 8.4 + Laravel 12.x + PostgreSQL 16 + Redis
- **`templates/legacy-php74/`** - PHP 7.4 for legacy projects

## Gaming (vm only)

```bash
# Launch Steam
steam

# Run with GameMode for better performance
gamemoderun %command%
```

## Adding a New Host

1. Create host directory and generate hardware config:
```bash
mkdir -p hosts/new-host
nixos-generate-config --show-hardware-config > hosts/new-host/hardware-configuration.nix
```

2. Create minimal `hosts/new-host/default.nix`:
```nix
{ ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/packages
  ];

  # Boot
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Network
  networking.hostName = "new-host";

  # Locale
  modules.locale.preset = "utc";

  # Hardware
  modules.hardware.bluetooth.enable = true;
  modules.hardware.virtualization.docker.enable = true;

  # User
  modules.users.mojodev.enable = true;
  modules.userSecrets.mojodev.enable = true;

  # Secrets
  modules.agenix.enable = true;

  # Display
  modules.displayManager.enable = true;

  system.stateVersion = "25.11";
}
```

3. Add to `flake.nix`:
```nix
nixosConfigurations = {
  # ... existing hosts
  new-host = lib.mkHost "new-host" [];
};
```

4. Build and deploy:
```bash
sudo nixos-rebuild switch --flake .#new-host
sudo passwd mojodev
sudo reboot
```

## Troubleshooting

### Module options not recognized

Ensure all modules are loaded in `lib/mkHost.nix` sharedModules array.

### Niri configuration not updating

```bash
niri validate
niri msg action load-config-file
```

### Home Manager backup conflicts

```bash
rm ~/.config/<app>/*.backup
sudo nixos-rebuild switch --flake .#<host>
```

## Credits

- **Niri** - Scrollable-tiling Wayland compositor
- **Home Manager** - Declarative user environment
- **Agenix** - Age-encrypted secrets for NixOS
- **Noctalia Shell** - Custom status bar
