{ config, pkgs, ... }:
{
  programs = {
    git = {
      enable = true;
     
      settings = {
        user = {
          name = "naito-7110";
          email = "shige.7110.330@gmail.com";
        };

         core = {
          editor = "nvim -f";
          autocrlf = "input";
          quotepath = false;
        };

        commit.verbose = true;

        color.status = {
          added = "green";
          changed = "red";
          untracked = "yellow";
          unmerged = "magenta";
        };

        pull.rebase = true;
        fetch.prune = true;

        push = {
          default = "current";
          autoSetupRemote = true;
        };

        rebase.autostash = true;

        status.showUntrackedFiles = "all";

        init.defaultBranch = "main";

        diff = {
          colorMoved = "default";
        };
      };
    };
    
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
