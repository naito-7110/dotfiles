{
  config,
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
    ./lsp.nix
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

      # nvim は頻繁に触るので store への read-only コピーではなく、リポジトリ実体への
      # out-of-store symlink にする。これで switch なしに編集が即反映される。
      # リポジトリは README のとおり ~/works/dotfiles に clone している前提。
      ".config/nvim".source =
        config.lib.file.mkOutOfStoreSymlink "${homeDirectory}/works/dotfiles/.config/nvim";
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
