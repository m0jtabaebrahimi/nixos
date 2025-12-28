# Agenix Secrets

This directory contains encrypted secrets managed by agenix.

## Usage

### Edit a secret
```bash
agenix -e secret-name.age
```

### Create a new secret
```bash
agenix -e new-secret.age
```

### Rekey all secrets
```bash
agenix-rekey
```

### Validate secrets
```bash
agenix --check
```

## Available Secrets

Add your secrets here with descriptions:

- `ppp-chap-secrets.age` - PPTP VPN credentials (username/password)
- `ppp-peers-iic-vpn.age` - PPTP VPN peer configuration
- `example-secret.age` - Example secret file
- `ssh-key.age` - SSH private key
- `api-token.age` - API authentication token

## Adding New Secrets

1. Create the encrypted file:
   ```bash
   agenix -e your-secret.age
   ```

2. Add to your NixOS configuration:
   ```nix
   age.secrets.your-secret = {
     file = ../../secrets/your-secret.age;
     mode = "600";
     owner = "username";
     group = "users";
   };
   ```

3. Rebuild your system:
   ```bash
   sudo nixos-rebuild switch --flake .#hostname
   ```

## Security Notes

- Never commit unencrypted secrets
- Use strong SSH keys for encryption
- Regularly rotate your secrets
- Keep backup of your SSH keys