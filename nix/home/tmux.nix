{ ... }:
{
  programs.tmux = {
    enable = true;
    prefix = "C-q";
    escapeTime = 0;
    baseIndex = 1;
    terminal = "tmux-256color";

    extraConfig = ''
      # nvim 等のフルカラー対応
      set -ag terminal-overrides ",xterm-256color:RGB"

      # ペイン分割（カレントディレクトリを引き継ぐ）
      bind '\' split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"

      # ペイン移動 (vim 風 hjkl)
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R
    '';
  };
}
