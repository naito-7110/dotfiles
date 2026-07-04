{ ... }:
{
  programs.tmux = {
    enable = true;
    prefix = "C-q";
    escapeTime = 0;
    baseIndex = 1;
    terminal = "tmux-256color";
    historyLimit = 10000;
    mouse = true;

    extraConfig = ''
      # nvim 等のフルカラー対応
      set -ag terminal-overrides ",xterm-256color:RGB"

      # ステータスバー
      set-option -g status-position top
      set-option -g status-justify centre
      set-option -g status-left-length 90
      set-option -g status-right-length 90
      set-option -g status-right ""
      set-option -g status-bg "colour233"
      set-option -g status-fg "colour255"

      # ペイン境界線 (アクティブを見分けやすく)
      set-option -g pane-border-style "fg=colour238"
      set-option -g pane-active-border-style "fg=colour51"

      # 各ペイン上部にカレントパスを表示
      # home 配下は ~ に短縮 (/home/<user> と /Users/<user> の両方に対応)
      # claude が動いているペインは、端末タイトル (=タスク要約) を末尾に付けて識別しやすくする
      set-option -g pane-border-status top
      set-option -g pane-border-format " #[bold]#{pane_index}#[nobold] #{s,^/(home|Users)/[^/]+,~,:pane_current_path}#{?#{==:#{pane_current_command},claude},  #[fg=colour51]#{pane_title}#[default],} "

      # ウィンドウ名: claude のときは端末タイトル (タスク要約) を使う
      # → 複数の claude を開いてもステータスバーの一覧で区別できる (既定は pane_current_command で全部 "claude" になる)
      set-option -g automatic-rename-format "#{?#{==:#{pane_current_command},claude},#{pane_title},#{pane_current_command}}"

      # ペイン分割（カレントディレクトリを引き継ぐ）
      bind '\' split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"

      # 新規ウィンドウ (カレントディレクトリを引き継ぐ)
      bind c new-window -c "#{pane_current_path}"

      # ペイン移動 (vim 風 hjkl)
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R

      # ネストした tmux に prefix を送る
      bind C-q send-prefix
    '';
  };
}
