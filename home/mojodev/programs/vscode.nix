{ config, pkgs, ... }:

{
  # VS Code configuration

  programs.vscode = {
    enable = true;
    package = pkgs.vscode.fhs;

    # Default profile configuration
    profiles.default = {
      # Extensions
      extensions = with pkgs.vscode-extensions; [
        # Nix
        jnoortheen.nix-ide

        # Ansible
        redhat.ansible

        # YAML
        redhat.vscode-yaml

        # Go
        golang.go

        # Git
        eamodio.gitlens

        # PHP
        bmewburn.vscode-intelephense-client
      ] ++ [
        # Laravel extensions (from marketplace, not in nixpkgs)
        # Install manually: Laravel (amiralizadeh9480.laravel-extra-intellisense)
        # Install manually: Laravel Extension Pack (onecentlin.laravel-extension-pack)
      ];

      # User settings
      userSettings = {
      # Disable telemetry
      "redhat.telemetry.enabled" = false;

      # Ansible settings
      "[ansible]" = {
        "editor.detectIndentation" = true;
        "editor.insertSpaces" = true;
        "editor.tabSize" = 2;
        "editor.quickSuggestions" = {
          "comments" = true;
          "other" = true;
          "strings" = true;
        };
        "editor.autoIndent" = "advanced";
        "editor.renderWhitespace" = "all";
      };
      "ansible.ansible.useFullyQualifiedCollectionNames" = false;
      "workbench.settings.applyToAllProfiles" = [
        "ansible.ansible.useFullyQualifiedCollectionNames"
      ];

      # Terminal settings
      "terminal.integrated.defaultProfile.osx" = "zsh";
      "terminal.external.osxExec" = "iTerm.app";
      "terminal.integrated.fontFamily" = "JetBrainsMono Nerd Font";
      "terminal.integrated.fontSize" = 16;

      # YAML settings
      "[yaml]" = {
        "editor.renderWhitespace" = "all";
      };

      # Git settings
      "git.enableSmartCommit" = true;
      "git.openRepositoryInParentFolders" = "never";
      "git.confirmSync" = false;

      # Editor settings
      "editor.wordSeparators" = "`~!@#%^&*()-=+[{]}\\|;:'\",.<>/?";
      "files.trimTrailingWhitespace" = true;

      # Appearance
      "workbench.colorTheme" = "Default Light Modern";

      # Laravel settings
      "Laravel.phpEnvironment" = "sail";

      # Go settings
      "go.toolsManagement.autoUpdate" = true;

      # Claude Code settings
      "claudeCode.preferredLocation" = "panel";
      };
    };
  };

  # Override the VSCode desktop entry to use Wayland flags
  xdg.desktopEntries.code = {
    name = "Visual Studio Code";
    genericName = "Text Editor";
    exec = "${pkgs.vscode.fhs}/bin/code --enable-features=UseOzonePlatform --ozone-platform=wayland %F";
    terminal = false;
    categories = [ "Utility" "TextEditor" "Development" "IDE" ];
    mimeType = [ "text/plain" "inode/directory" ];
    icon = "vscode";
    startupNotify = true;
    comment = "Code Editing. Redefined.";
  };
}
