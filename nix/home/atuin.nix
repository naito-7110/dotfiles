{ ... }:
{
  # シェル履歴を SQLite で持ち、Ctrl-R をファジー全文検索にする。実行ディレクトリ・
  # 終了コード・所要時間も記録されるので「このプロジェクトで成功したコマンド」に絞れる。
  # zsh 連携（enableZshIntegration）は既定で有効。Ctrl-R の最終的な bind は
  # fzf 統合と衝突しないよう zsh.nix 側で mkAfter して atuin に確定させている。
  programs.atuin = {
    enable = true;

    # 上矢印は zsh 標準の履歴のまま残す（autosuggestion と併用したいので atuin に奪わせない）。
    # Ctrl-R だけ atuin に任せる。
    flags = [ "--disable-up-arrow" ];

    settings = {
      # 起動時は全履歴。検索中に Ctrl-R でディレクトリ別/セッション別へ切り替えられる。
      filter_mode = "global";
      # Enter は「選んで行に載せるだけ」。中身を確認してから自分で実行する（誤爆防止）。
      enter_accept = false;
      style = "compact";
      # 同期は既定の無効のまま（ローカル完結）。揃えたくなったら `atuin login` で有効化する。
    };
  };
}
