# Legacy PHP 7.4 Development Environment
# For older Laravel/PHP projects that require PHP 7.4
#
# Note: PHP 7.4 is EOL. This uses an older nixpkgs version.
#
# Usage:
#   1. Copy devenv.nix and devenv.yaml to your project root
#   2. Run: devenv init (if .envrc doesn't exist)
#   3. Run: direnv allow
#   4. Environment activates automatically when you cd into the directory

{ pkgs, lib, inputs, ... }:

let
  # Use PHP 7.4 from the legacy nixpkgs input
  php74 = inputs.nixpkgs-php74.legacyPackages.${pkgs.stdenv.hostPlatform.system}.php74;
in
{
  # Environment variables
  env = {
    APP_ENV = "local";
    APP_DEBUG = "true";
    DB_CONNECTION = "pgsql";
    DB_HOST = "127.0.0.1";
    DB_PORT = "5432";
    DB_DATABASE = "laravel";
    DB_USERNAME = "laravel";
    DB_PASSWORD = "secret";
  };

  # Packages available in the environment
  packages = with pkgs; [
    # Build tools
    gnumake
    gcc

    # PHP 7.4 and extensions
    php74
    php74.packages.composer

    # Database tools
    postgresql

    # Node.js (use older LTS for compatibility)
    nodejs_18
    nodePackages.npm

    # Utilities
    curl
    jq
    git
  ];

  # PHP configuration (manual since we're using custom PHP)
  languages.php = {
    enable = true;
    package = php74;

    fpm.pools.web = {
      settings = {
        "pm" = "dynamic";
        "pm.max_children" = 10;
        "pm.start_servers" = 2;
        "pm.min_spare_servers" = 1;
        "pm.max_spare_servers" = 5;
      };
    };

    ini = ''
      memory_limit = 512M
      upload_max_filesize = 100M
      post_max_size = 100M
      max_execution_time = 300

      ; Xdebug 2.x configuration (for PHP 7.4)
      xdebug.remote_enable = 1
      xdebug.remote_host = 127.0.0.1
      xdebug.remote_port = 9000
      xdebug.remote_autostart = 1
      xdebug.idekey = VSCODE
    '';
  };

  # Services
  services.postgres = {
    enable = true;
    package = pkgs.postgresql_14;
    initialDatabases = [{ name = "laravel"; }];
    initialScript = ''
      CREATE USER laravel WITH PASSWORD 'secret' CREATEDB;
      GRANT ALL PRIVILEGES ON DATABASE laravel TO laravel;
    '';
    listen_addresses = "127.0.0.1";
    port = 5432;
  };

  # Web server
  services.caddy = {
    enable = true;
    config = ''
      :8080 {
        root * {$DEVENV_ROOT}/public
        php_fastcgi unix///{$DEVENV_STATE}/php-fpm/web.sock
        file_server
        encode gzip
        try_files {path} {path}/ /index.php?{query}
      }
    '';
  };

  # Scripts
  scripts = {
    art.exec = ''
      php artisan "$@"
    '';

    dev-install.exec = ''
      composer install
      npm install
      cp -n .env.example .env || true
      php artisan key:generate --ansi
      php artisan migrate --seed
      npm run dev
    '';
  };

  # Shell hook
  enterShell = ''
    echo ""
    echo "⚠️  Legacy PHP 7.4 Development Environment"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "PHP:        $(php -v | head -1)"
    echo "Composer:   $(composer --version | head -1)"
    echo "Node.js:    $(node --version)"
    echo ""
    echo "⚠️  Warning: PHP 7.4 is END OF LIFE!"
    echo "   Consider upgrading to PHP 8.x"
    echo ""
    echo "📋 Available commands:"
    echo "  devenv up      - Start services"
    echo "  art <cmd>      - Laravel artisan"
    echo "  dev-install    - Install dependencies"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
  '';
}
