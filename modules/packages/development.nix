# Development tools and languages
# Programming languages, IDEs, and development utilities

{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Editors and IDEs
    vscode.fhs
    helix

    # Version control
    git

    # API and database tools
    insomnia
    dbeaver-bin

    # Development environments
    devenv
    direnv

    # Programming languages
    php83
    php83Packages.composer

    # Containerization
    docker
    docker-compose

    # AI development tools
    ollama
    claude-code
    opencode
  ];

  # Enable direnv with nix-direnv for automatic environment switching
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # Trust devenv cache for faster builds
  nix.settings.trusted-substituters = [
    "https://devenv.cachix.org"
  ];
  nix.settings.trusted-public-keys = [
    "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
  ];
}
