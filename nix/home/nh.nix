{ homeDirectory, ... }:
{
  # nix コマンドの薄いラッパー。switch 時に「何が追加/更新/削除されるか」を
  # ツリー差分で見せる。GC も `nh clean all` 一発。mac / WSL とも同じ CLI で回せる。
  #   WSL : nh home switch
  #   mac : nh darwin switch
  programs.nh = {
    enable = true;
    # nh のデフォルト flake（FLAKE 環境変数も張られる）。明示パス指定でも上書きできる。
    flake = "${homeDirectory}/works/dotfiles";
    # clean.enable は systemd/launchd の定期GCタイマーを張るが、WSL では
    # systemd user 依存で環境差が出るため自動化はしない。GC は `nh clean all` を手動で。
  };
}
