{ config, pkgs, username, ... }:
{
  home.username = username;
  home.homeDirectory = "/home/${username}";
  programs.home-manager.enable = true;
  imports = [ ./hypr/hyprland.conf.nix ];
  home.packages = with pkgs; [ bat fzf zoxide neofetch vscode neovim starship atuin texlive.combined.scheme-full ];
  xdg.configFile."starship.toml".text = ''
    [character]
    symbol = "➜"
    error_symbol = "✘"
    use_symbol_for_status = true
    format = "$all"
  '';
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    configure = { packages.myPlugins = with pkgs.vimPlugins; [ vim-nix vim-plug coc-nvim vimtex ]; };
  };
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
    initExtra = ''
      if command -v atuin >/dev/null 2>&1; then
        eval "$(atuin init zsh)"
      fi
      if command -v starship >/dev/null 2>&1; then
        eval "$(starship init zsh)"
      fi
    '';
  };
  programs.git = { enable = true; userName = "Sevi Dervishi"; userEmail = "you@example.com"; };
  home.stateVersion = "24.05";
}
