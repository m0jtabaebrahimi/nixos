# Laravel 12.x Development Environment
# PHP 8.4 + Apache + PostgreSQL + Node.js + Composer + Xdebug
#
# Usage:
#   1. Copy this file to your Laravel project root
#   2. Run: devenv init (if .envrc doesn't exist)
#   3. Run: direnv allow
#   4. Environment activates automatically when you cd into the directory
#
# Services:
#   - Apache: http://localhost:8080
#   - PostgreSQL: localhost:5432
#   - MailHog: http://localhost:8025

{ pkgs, lib, ... }:

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

    # Database tools
    postgresql

    # Node.js for frontend assets
    nodejs_22
    nodePackages.npm

    # PHP tools
    phpPackages.composer

    # Utilities
    curl
    jq
    git
  ];

  # PHP configuration
  languages.php = {
    enable = true;
    package = pkgs.php84;

    # PHP-FPM configuration
    fpm.pools.web = {
      settings = {
        "pm" = "dynamic";
        "pm.max_children" = 10;
        "pm.start_servers" = 2;
        "pm.min_spare_servers" = 1;
        "pm.max_spare_servers" = 5;
      };
    };

    # PHP extensions
    extensions = [ "pdo" "pdo_pgsql" "pgsql" "mbstring" "xml" "curl" "zip" "gd" "intl" "bcmath" "redis" "xdebug" ];

    # PHP settings
    ini = ''
      memory_limit = 512M
      upload_max_filesize = 100M
      post_max_size = 100M
      max_execution_time = 300

      ; Xdebug configuration
      xdebug.mode = debug,develop,coverage
      xdebug.start_with_request = yes
      xdebug.client_host = 127.0.0.1
      xdebug.client_port = 9003
      xdebug.log = /tmp/xdebug.log
      xdebug.idekey = VSCODE
    '';
  };

  # JavaScript/Node.js
  languages.javascript = {
    enable = true;
    package = pkgs.nodejs_22;
    npm.enable = true;
  };

  # Services
  services.postgres = {
    enable = true;
    package = pkgs.postgresql_16;
    initialDatabases = [{ name = "laravel"; }];
    initialScript = ''
      CREATE USER laravel WITH PASSWORD 'secret' CREATEDB;
      GRANT ALL PRIVILEGES ON DATABASE laravel TO laravel;
    '';
    listen_addresses = "127.0.0.1";
    port = 5432;
  };

  # Apache with PHP-FPM
  services.caddy = {
    enable = true;
    config = ''
      :8080 {
        root * {$DEVENV_ROOT}/public
        php_fastcgi unix///{$DEVENV_STATE}/php-fpm/web.sock
        file_server
        encode gzip

        # Laravel friendly URLs
        try_files {path} {path}/ /index.php?{query}
      }
    '';
  };

  # MailHog for email testing
  services.mailhog = {
    enable = true;
  };

  # Redis for caching/queues (optional)
  services.redis = {
    enable = true;
    port = 6379;
  };

  # Scripts available in the environment
  scripts = {
    # Start all services
    dev-start.exec = ''
      echo "Starting development services..."
      devenv up
    '';

    # Laravel artisan shortcut
    art.exec = ''
      php artisan "$@"
    '';

    # Run Laravel tests
    test.exec = ''
      php artisan test "$@"
    '';

    # Fresh database migration
    db-fresh.exec = ''
      php artisan migrate:fresh --seed
    '';

    # Install project dependencies
    dev-install.exec = ''
      composer install
      npm install
      cp -n .env.example .env || true
      php artisan key:generate --ansi
      php artisan migrate --seed
      npm run build
    '';
  };

  # Pre-commit hooks (optional)
  pre-commit.hooks = {
    # PHP linting
    # php-cs-fixer.enable = true;

    # JavaScript linting
    # eslint.enable = true;
  };

  # Shell hook - runs when entering the environment
  enterShell = ''
    echo ""
    echo "🚀 Laravel 12.x Development Environment"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "PHP:        $(php -v | head -1)"
    echo "Composer:   $(composer --version | head -1)"
    echo "Node.js:    $(node --version)"
    echo "npm:        $(npm --version)"
    echo ""
    echo "📋 Available commands:"
    echo "  devenv up      - Start all services (Apache, PostgreSQL, Redis, MailHog)"
    echo "  art <cmd>      - Laravel artisan shortcut"
    echo "  test           - Run Laravel tests"
    echo "  db-fresh       - Fresh migration with seeding"
    echo "  dev-install    - Install all dependencies"
    echo ""
    echo "🌐 Services (after 'devenv up'):"
    echo "  App:     http://localhost:8080"
    echo "  MailHog: http://localhost:8025"
    echo "  Redis:   localhost:6379"
    echo "  PgSQL:   localhost:5432"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
  '';
}
