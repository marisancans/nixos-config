{ config, pkgs, ... }:

{
  home.username = "ma";
  home.homeDirectory = "/home/ma";
  home.stateVersion = "22.11";

  programs.home-manager.enable = true;
  nixpkgs.config.allowUnfree = true;

  programs.zsh = {
    enable = true;
    shellAliases = {
      ll = "ls -lha";
      switch = "sudo nixos-rebuild switch --flake .#ma";
      build = "sudo nixos-rebuild build --flake .#ma";
    };
    history = {
      size = 10000;
      path = "${config.xdg.dataHome}/zsh/history";
    };
    plugins = [
      {
        name = "powerlevel10k";
        src = pkgs.zsh-powerlevel10k;
        file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      }
      {
        name = "powerlevel10k-config";
        src = ./dotfiles/p10k-config;
        file = "p10k.zsh";
      }
    ];

    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "thefuck"
        "fzf"
      ];
      theme = "robbyrussell";
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
    htop
    pciutils
    git
    kitty


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
    nerdfonts

    thefuck
    fzf

    zsh-powerlevel10k

    rofi
    libusb1
    wally-cli
    
  ];




  # Copy all dotfiles
  home.file.".config/hypr".source = dotfiles/hypr;
  home.file.".config/waybar".source = dotfiles/waybar;
  home.file.".config/kitty".source = dotfiles/kitty;
}
