# AGENTS.md - Coding Guidelines for NixOS Configuration Repository

## Build Commands
```bash
# Build configurations (test without switching)
sudo nixos-rebuild build --flake .#laptop
sudo nixos-rebuild build --flake .#iic-pc  
sudo nixos-rebuild build --flake .#vm

# Build and switch to configuration
sudo nixos-rebuild switch --flake .#hostname
```

## Lint and Validation
```bash
# Validate Niri configuration
niri validate

# Reload Niri configuration
niri msg action load-config-file

# Format Nix files
nixfmt *.nix

# Validate secrets
agenix --check
```

## Code Style Guidelines

### General Nix Conventions
- Use 2 spaces for indentation
- Follow Nix language style guide
- Keep expressions concise and readable
- Use meaningful variable names
- Prefer `let` expressions for complex calculations

### Imports and Dependencies
- Import from relative paths when possible
- Use `pkgs` for package references
- Follow flake input structure as shown in flake.nix
- Keep inputs organized and documented

### Naming Conventions
- Host names: lowercase (laptop, iic-pc, vm)
- Module names: descriptive (wm/niri.nix, programs/zsh.nix)
- Variables: camelCase or snake_case as appropriate
- Configuration options: use NixOS standard names

### Error Handling
- Use `assert` for critical validations
- Provide meaningful error messages
- Handle optional values gracefully
- Test configurations before deployment

### Niri Configuration
- Use KDL format for niri config
- Apply host-specific settings via `osConfig.networking.hostName`
- Keep hotkey bindings organized
- Test window rules with `niri validate`

### Testing
- Build each host configuration separately
- Validate Niri config after changes
- Test proxy/VPN settings on iic-pc
- Verify Home Manager integration
- Validate secrets with `agenix --check` before rebuild

### Agenix Secrets Management
- Use `agenix -e secret-name.age` to edit secrets
- Store encrypted secrets in `secrets/` directory
- Add secrets to configuration using `age.secrets.*`
- Never commit unencrypted secrets to git
- Use SSH keys for encryption (host and user keys)