{ config, pkgs, ... }:
{
  imports = [
    ./git.nix
  ];
  
  programs = {
    starship.enable = true;
    neovim.enable = true;
    fzf.enable = true;
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
  };

  home = {
    username = "n7110";
    homeDirectory = "/Users/n7110";
    stateVersion = "24.05";
    
    file = {
      ".config/starship.toml".source =  ../../.config/starship/starship.toml;
      ".config/nvim".source = ../../.config/nvim;
      ".config/wezterm".source = ../../.config/wezterm;
    };
    
    packages = with pkgs; [
      direnv
      nix-direnv
      lazygit
      fzf
      mise
      docker
      kubectl
      gh
      git-secrets
    ];
  };
}
