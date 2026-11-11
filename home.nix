{ config, pkgs, ... }:

let
  dotfiles = "${config.home.homeDirectory}/nixos-dotfiles/config";
  create_symlink = path: config.lib.file.mkOutOfStoreSymlink path;

  # Standard .config/directory
  configs = {
    qtile = "qtile";
    nvim = "nvim";
    rofi = "rofi";
    alacritty = "alacritty";
    picom = "picom";
  };
in

{
  home.username = "sese";
  home.homeDirectory = "/home/sese";
  programs.git.enable = true;
  home.stateVersion = "26.05";
  programs.bash = {
    enable = true;
    shellAliases = {
      btw = "echo i use nixos-btw";
      nrs = "sudo nixos-rebuild switch --flake ~/nixos-dotfiles#zenbook";
    };
    initExtra = ''
      	  export PS1="\[\e[38;5;75m\]\u@\h \[\e[38;5;113m\]\w \[\e[38;5;189m\]\$ \[\e[0m\]"
      	'';
  };

  xdg.configFile = builtins.mapAttrs
    (name: subpath: {
      source = create_symlink "${dotfiles}/${subpath}";
      recursive = true;
    })
    configs;

  home.packages = with pkgs; [
    neovim
    ripgrep
    nil
    nixpkgs-fmt
    nodejs
    gcc
    rofi
    xwallpaper
  ];
programs.git = {
	ernable = true;
	userName = "Sevi Dervishi";
	userEmnail = "sevidervishi@outlook.fr";
	extraConfig = {
	init.defaultBranch = "main";
};
};

}
