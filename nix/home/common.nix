{
  pkgs,
  pkgs-master,
  username,
  homeDirectory,
  ...
}:
{
  imports = [
    ./git.nix
    ./zsh.nix
    ./zoxide.nix
    ./lazygit.nix
    ./tmux.nix
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
    inherit username homeDirectory;
    stateVersion = "24.05";

    file = {
      ".config/starship.toml".source = ../../.config/starship/starship.toml;
      ".config/nvim".source = ../../.config/nvim;
    };

    # OS非依存の共通パッケージ。OS固有は darwin.nix / linux.nix で追加する。
    packages = with pkgs; [
      direnv
      nix-direnv
      fzf
      ripgrep
      fd
      bat
      mise
      kubectl
      gh
      git-secrets

      pkgs-master.claude-code

      ffmpeg
      poppler-utils
    ];
  };
}
