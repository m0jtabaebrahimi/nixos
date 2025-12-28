# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a highly modular, Flake-based NixOS configuration repository managing multiple machines with Home Manager integration. The configuration follows **DRY (Don't Repeat Yourself)** principles with a clear module hierarchy using the `modules.*` namespace. All configurations use nixpkgs unstable and include custom Niri window manager setup.

**Key architectural principles:**
- Custom NixOS modules with enable options pattern
- Composable profiles for common use cases
- Two-tier secrets architecture (host-level and user-level)
- Minimal host-specific configuration files (~40 lines each)
- Shared modules loaded via `lib/mkHost.nix`

## Build and Deploy Commands

### Building configurations
```bash
# Build without switching (for testing)
sudo nixos-rebuild build --flake .#iic-pc
sudo nixos-rebuild build --flake .#laptop
sudo nixos-rebuild build --flake .#vm

# Build and switch to configuration
sudo nixos-rebuild switch --flake .#iic-pc
sudo nixos-rebuild switch --flake .#laptop
sudo nixos-rebuild switch --flake .#vm
```

### Niri window manager commands
```bash
# Validate Niri configuration
niri validate

# Reload Niri configuration (after changes to home/mojodev/desktop/niri.nix)
niri msg action load-config-file
```

### VPN

#### iic-pc (PPTP VPN)
```bash
# Connect to VPN
sudo pon iic-vpn

# Disconnect from VPN
sudo poff iic-vpn
```

**Note**: PPTP credentials are managed with agenix:
```bash
# Edit VPN credentials (shared across all PPTP connections)
agenix -e ppp-chap-secrets.age

# Edit VPN peer configuration (specific to this connection)
agenix -e ppp-peers-iic-vpn.age
```

**Multi-Host PPTP Support**: Each host can have its own PPTP connection with different credentials:
- Connection name is configurable per-host (e.g., `iic-vpn`, `iic-vpn-ati`)
- Each connection requires its own peers file (`ppp-peers-<connection-name>.age`)
- Credentials can be shared (same `ppp-chap-secrets.age`) or separate per host

#### vm (ProtonVPN)
```bash
# Launch ProtonVPN GUI
protonvpn-gui

# Or launch from rofi (Mod+D and search for "ProtonVPN")
```

### Gaming (vm only)

#### Steam
```bash
# Launch Steam
steam

# Or launch from rofi (Mod+D and search for "Steam")

# GameMode is enabled - compatible games will automatically use it for better performance
# To manually run a game with GameMode:
gamemoderun %command%
```

**Note**: The VM uses VirtualBox, so 3D gaming performance may be limited. For better performance:
- Ensure VirtualBox Guest Additions are installed and 3D acceleration is enabled in VM settings
- Allocate sufficient RAM and CPU cores to the VM

## Architecture

### Flake Structure
- **flake.nix**: Entry point defining three nixosConfigurations using `lib.mkHost`
- **lib/mkHost.nix**: Host builder function that loads all shared modules
- All configurations use the same user (`mojodev`) with shared Home Manager setup
- Home Manager is integrated via `nixosModules.home-manager` with `extraSpecialArgs` to pass flake inputs

### Modular Architecture

The configuration uses a hierarchical module system with the `modules.*` namespace:

```
modules/
├── core/          # Foundation layer (always enabled)
│   ├── nix.nix           # Nix settings, flakes, unfree packages
│   ├── locale.nix        # Locale with timezone presets
│   ├── networking.nix    # NetworkManager base
│   └── security.nix      # Sudo, polkit
│
├── hardware/      # Hardware enablement (opt-in)
│   ├── bluetooth.nix
│   ├── audio.nix
│   ├── graphics/gaming.nix
│   └── virtualization/
│       ├── docker.nix
│       └── virtualbox.nix
│
├── services/      # Optional services
│   ├── ssh.nix
│   ├── vpn/pptp.nix
│   └── proxy.nix
│
├── users/         # User management
│   ├── mojodev.nix       # User definition
│   └── secrets.nix       # User-level secrets
│
├── secrets/       # Host-level secrets
│   └── host-secrets.nix  # VPN, system credentials
│
├── packages/      # Organized package sets
│   ├── base.nix          # CLI tools
│   ├── development.nix   # Dev tools
│   ├── desktop.nix       # GUI apps
│   └── wayland.nix       # Niri ecosystem
│
└── profiles/      # Composable bundles
    ├── desktop.nix       # Full desktop (bluetooth + audio + packages)
    └── development.nix   # Desktop + Docker
```

### Directory Organization

**lib/** - Custom Nix functions
- `mkHost.nix`: Host builder function centralizing shared modules
- `helpers.nix`: Utility functions

**overlays/** - Nixpkgs overlays
- `default.nix`: NUR overlay

**hosts/** - Machine-specific NixOS configurations (~40 lines each)
- Each host has `default.nix` (system config) and `hardware-configuration.nix` (hardware-specific)
- `iic-pc`: Desktop PC with PPTP VPN, SDDM with auto-login, Niri WM, proxy configuration
- `laptop`: Basic laptop configuration with minimal setup
- `vm`: Virtual machine configuration with gaming support

**home/** - User-level Home Manager configurations
- `home/mojodev/default.nix`: Main user configuration importing all program and desktop modules
- `home/mojodev/programs/`: Program-specific configurations (flat structure: zsh.nix, vscode.nix, alacritty.nix, etc.)
- `home/mojodev/desktop/`: Desktop environment (niri.nix, waybar.nix, noctalia.nix)

**modules/** - Shared NixOS modules (see Modular Architecture above)

**secrets/** - Agenix encrypted secrets
- `secrets.nix`: Public key mappings
- `ppp-chap-secrets.age`: PPTP credentials
- `ppp-peers-iic-vpn.age`: PPTP peer config
- `mojodev-secrets.age`: User environment variables

**templates/** - Development environment templates
- `laravel-php84/`: PHP 8.4 + Laravel 12.x + PostgreSQL 16 + Redis
- `legacy-php74/`: PHP 7.4 for legacy projects

### Key Design Patterns

1. **Module Options Pattern**: All modules use enable options with sensible defaults
   ```nix
   modules.hardware.bluetooth.enable = true;
   modules.hardware.bluetooth.powerOnBoot = true;  # default
   ```

2. **Locale Presets**: Predefined timezone/locale combinations
   ```nix
   modules.locale.preset = "persian";  # Asia/Tehran + fa_IR
   modules.locale.preset = "utc";      # UTC + en_US (default)
   ```

3. **Two-Tier Secrets Architecture**:
   - Host-level secrets (root-owned): VPN credentials, system configs
     ```nix
     modules.secrets.pptpVpn = {
       enable = true;
       connectionName = "iic-vpn";
       chapSecretsFile = ../../secrets/ppp-chap-secrets.age;
       peersFile = ../../secrets/ppp-peers-iic-vpn.age;
     };
     ```
   - User-level secrets (mojodev-owned): env vars, SSH keys, API tokens
     ```nix
     modules.userSecrets.mojodev.enable = true;
     modules.userSecrets.mojodev.sshKeys = true;
     modules.userSecrets.mojodev.apiTokens = true;
     ```

4. **Composable Profiles**: Bundle multiple modules for common use cases
   ```nix
   imports = [ ../../modules/profiles/desktop.nix ];
   # Automatically enables bluetooth, audio, and packages
   ```

5. **Host-specific conditionals**: Niri configuration uses `osConfig.networking.hostName` to apply host-specific output settings (display resolution/scaling)

6. **Flake inputs**:
   - `nixpkgs` from nixos-unstable
   - `home-manager` following nixpkgs
   - `noctalia-shell` custom package
   - `agenix` for encrypted secrets

7. **User configuration**: All hosts share the same user `mojodev` with identical Home Manager setup, allowing consistent environment across machines

## Module System Usage

### Core Modules (Always Enabled)

Automatically applied to all hosts via `lib/mkHost.nix`:
- Nix settings, flakes, unfree packages
- Locale with timezone presets
- NetworkManager base
- Passwordless sudo for wheel group

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
modules.services.vpn.pptp = {
  enable = true;
  connectionName = "iic-vpn";  # or "iic-vpn-ati", etc.
  allowPasswordlessSudo = true;  # default
};
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

# Host secrets - PPTP VPN
modules.secrets.pptpVpn = {
  enable = true;
  connectionName = "iic-vpn";  # Must match the service connectionName
  chapSecretsFile = ../../secrets/ppp-chap-secrets.age;
  peersFile = ../../secrets/ppp-peers-iic-vpn.age;
};
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

## Important Configuration Details

### Niri Configuration
- Configuration file is generated via `xdg.configFile."niri/config.kdl"` in `home/mojodev/desktop/niri.nix`
- Uses KDL (KDL Document Language) format
- Host-specific output configuration based on hostname
- After modifying niri.nix, rebuild Home Manager and then run `niri msg action load-config-file`

### iic-pc Specifics
- PPTP VPN `iic-vpn` for connecting to internal network (managed with agenix)
  - Connection name: `iic-vpn`
  - Secrets: `ppp-chap-secrets.age` and `ppp-peers-iic-vpn.age`
- SDDM display manager with auto-login disabled
- Locale preset: `persian` (Asia/Tehran timezone)
- Uses NetworkManager's default DNS handling

### laptop Specifics
- Minimal configuration with no auto-login (more secure for portable device)
- Locale preset: `utc`
- Docker enabled for development

### vm Specifics
- Gaming support via `modules.hardware.graphics.gaming.enable`
- VirtualBox guest additions enabled
- ProtonVPN GUI installed
- Locale preset: `persian`

### Home Manager Integration
- Home Manager state version: 24.11
- Programs configured declaratively through separate module files (flat structure)
- Desktop environment configs in `home/mojodev/desktop/`
- Session variables set for WLR renderer compatibility (`WLR_RENDERER=pixman`, `WLR_NO_HARDWARE_CURSORS=1`)

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

## Secrets Management (Agenix)

### Host-Level Secrets (root-owned)
Managed via `modules.secrets.*`:
```nix
# PPTP VPN secrets (flexible per-host configuration)
modules.secrets.pptpVpn = {
  enable = true;
  connectionName = "iic-vpn";  # Connection name
  chapSecretsFile = ../../secrets/ppp-chap-secrets.age;
  peersFile = ../../secrets/ppp-peers-iic-vpn.age;
};
```

Files in `secrets/`:
- `ppp-chap-secrets.age` - PPTP credentials (can be shared or per-host)
- `ppp-peers-<connection-name>.age` - PPTP peer config (per-connection)
  - `ppp-peers-iic-vpn.age` for `iic-vpn` connection
  - `ppp-peers-iic-vpn-ati.age` for `iic-vpn-ati` connection

### User-Level Secrets (mojodev-owned)
Managed via `modules.userSecrets.mojodev.*`:
```nix
modules.userSecrets.mojodev.enable = true;      # enables .secrets.env
modules.userSecrets.mojodev.sshKeys = true;     # enables private SSH keys
modules.userSecrets.mojodev.apiTokens = true;   # enables API tokens
```

Files in `secrets/`:
- `mojodev-secrets.age` - Environment variables (`.secrets.env`)
- `mojodev-ssh-keys.age` - Private SSH keys
- `mojodev-api-tokens.age` - API tokens

### Editing Secrets
```bash
# Edit any secret file
agenix -e <secret-name>.age

# Examples - PPTP VPN
agenix -e ppp-chap-secrets.age           # Edit PPTP credentials
agenix -e ppp-peers-iic-vpn.age          # Edit iic-vpn peer config
agenix -e ppp-peers-iic-vpn-ati.age      # Edit iic-vpn-ati peer config

# Examples - User secrets
agenix -e mojodev-secrets.age            # Edit user environment variables
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

### Finding where a module is defined
Use grep to search the modules directory:
```bash
grep -r "modules.hardware.bluetooth" modules/
```

### Understanding what a host enables
Check the host's `default.nix` file - all enabled modules are listed at the top:
```bash
cat hosts/iic-pc/default.nix
```

## Making Changes

### Adding a new system package
Add to appropriate file in `modules/packages/`:
- CLI tools → `base.nix`
- Dev tools/languages → `development.nix`
- GUI applications → `desktop.nix`
- Wayland/Niri tools → `wayland.nix`

### Adding a new Home Manager program
Create a new file in `home/mojodev/programs/<program>.nix` and import it in `home/mojodev/default.nix`.

### Enabling a feature for all hosts
Add it to appropriate profile in `modules/profiles/`, or add to `lib/mkHost.nix` sharedModules if it should always be available.

### Creating a new module
1. Create the module file in appropriate `modules/` subdirectory
2. Add it to `lib/mkHost.nix` sharedModules array
3. Use the enable option pattern:
   ```nix
   options.modules.category.feature.enable = lib.mkEnableOption "feature description";
   config = lib.mkIf cfg.enable { /* configuration */ };
   ```

## User Migration Notes

The repository shows evidence of migration from user `mojtaba` to `mojodev`. When adding a new host or migrating:

1. Build configuration first: `sudo nixos-rebuild build --flake .#hostname`
2. Switch configuration: `sudo nixos-rebuild switch --flake .#hostname`
3. Set password: `sudo passwd mojodev`
4. Reboot system
