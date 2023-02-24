{ config, pkgs, ... }:

{
  home.username = "ma";
  home.homeDirectory = "/home/ma";
  home.stateVersion = "22.11";

  programs.home-manager.enable = true;

  programs.zsh = {
    enable = true;
    shellAliases = {
      ll = "ls -lha";
#       update = "sudo nixos-rebuild switch";
    };
    history = {
      size = 10000;
      path = "${config.xdg.dataHome}/zsh/history";
    };
    oh-my-zsh = {
      enable = true;
#       initExtra = ''
#         if zmodload zsh/terminfo && (( terminfo[colors] >= 256 )); then
#           [[ ! -f ${configThemeNormal} ]] || source ${configThemeNormal}
#         else
#           [[ ! -f ${configThemeTTY} ]] || source ${configThemeTTY}
#         fi
#       '';
      plugins = [
        "git"
        "thefuck"
#           {
#             name = "powerlevel10k-config";
#             src = ./conf;
#             file = "zsh-p10k.zsh";
#           }
      ];
      theme = "fox";
    };
  };


  wayland.windowManager.sway = {
    enable = true;
    config = rec {
      modifier = "Mod4";
      # Use kitty as default terminal
      terminal = "kitty";
      startup = [
        # Launch Firefox on start
        {command = "firefox";}
      ];
    };
  };

  # Development shells
  services.lorri.enable = true;

  home.packages = with pkgs; [
    kitty
    htop
    pciutils
    git


    waybar
    font-awesome # waybar unicode display

    (python3.withPackages(ps: [ ps.validators ps.selenium ps.pillow ]))

    swayimg # image overlay

    # Needed for sway
    polkit

    sway
    vscode

    # hyprland wallpaper
    hyprpaper

    # development shell
    direnv

    # For zsh powerlevel10k
    meslo-lgs-nf
  ];

  programs.kitty.settings.shell = "${pkgs.zsh}/bin/zsh";


  # Copy all dotfiles
  home.file.".config/hypr".source = .config/hypr;

}
