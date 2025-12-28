{ pkgs, ... }:

{
  programs.alacritty = {
    enable = true;
    settings = {
      font = {
        normal = {
          family = "JetBrainsMono Nerd Font";
          style = "Regular";
        };
        size = 12.0;
      };
      window = {
        opacity = 0.95;
        padding = {
          x = 10;
          y = 10;
        };
      };
    };
  };
}
