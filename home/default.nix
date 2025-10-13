{ pkgs, ... }: {
  home.packages = with pkgs; [
    starship
    neovim
    git
    fzf
    ripgrep
    fd
  ];

  programs.starship = {
    enable = true;
    settings = {
      format = "$all";
      add_newline = false;
      palette = "catppuccin-mocha";
      [module.user] format = "[$user]($style) ";
      [module.hostname] format = "[$hostname]($style) ";
      [module.directory] truncation_length = 3;
    };
  };

  programs.neovim = {
    enable = true;
    configure = {
      customRC = ''
        set tabstop=2
        set shiftwidth=2
        set expandtab
        set number
        set relativenumber
        set termguicolors
      '';
    };
  };
}

