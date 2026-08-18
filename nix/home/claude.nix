{
  pkgs,
  pkgs-master,
  lib,
  ...
}:
let
  # Claude Code の Stop フック: 「今の話題」を tmux のペイン local なユーザー
  # オプション @claude_topic に書く。表示は tmux.nix 側の pane-border-format /
  # automatic-rename-format が担当する (@claude_topic があれば優先、なければ
  # Claude Code がセッション冒頭に付ける pane_title の初期要約にフォールバック)。
  #
  # pane_title を直接書き換えないのは、Claude Code 自身が古い初期要約で
  # pane_title を頻繁に再セットするため (書いても数秒で上書きされる)。
  # ユーザーオプションなら Claude Code は触らないので奪い合いにならない。
  #
  # 設計:
  # - 各ターン終了時 (Stop) に発火し、前回更新から 5 分未満なら何もしない
  #   → 会話が動いたときだけ更新され、放置中は API を呼ばない
  # - 直近の会話ウィンドウを haiku に要約させる
  #   → 一度の脱線ではタイトルが変わらず、話題が本当に移ったときだけ変わる
  # - 話題が同じなら現在のラベルをそのまま返させて据え置く
  # ワーカーの切り離しに使う。& や二重フォークだけだとプロセスグループが
  # 変わらず、フック終了時の pgroup kill に巻き込まれて死ぬことがある。
  # setsid で新セッションに移せば生き残る (Linux のみ。darwin は素の & で妥協)
  setsidBin = lib.optionalString pkgs.stdenv.isLinux "${pkgs.util-linux}/bin/setsid";

  claude-tmux-topic = pkgs.writeShellScriptBin "claude-tmux-topic" ''
    # tmux 外や、要約用の内側 claude -p から呼ばれたときは何もしない (再帰ガード)
    [ -n "''${TMUX_PANE:-}" ] || exit 0
    [ -z "''${CLAUDE_TMUX_TOPIC_INNER:-}" ] || exit 0

    cache="''${XDG_CACHE_HOME:-$HOME/.cache}/claude-tmux-topic"
    mkdir -p "$cache"
    stamp="$cache/$(printf '%s' "$TMUX_PANE" | tr -c 'A-Za-z0-9' _).stamp"

    # SessionStart から「reset」で呼ばれたら前セッションの話題とスタンプを消す
    # (次の Stop でスロットリングを待たずに新しい話題が付く)
    if [ "''${1:-}" = "reset" ]; then
      tmux set-option -pu -t "$TMUX_PANE" @claude_topic 2>/dev/null
      rm -f "$stamp"
      exit 0
    fi

    # 切り離されたワーカー本体 ($2 = transcript パス)
    if [ "''${1:-}" = "worker" ]; then
      transcript="$2"

      # 直近の会話テキスト。ツール結果 / thinking / system-reminder は除外し、
      # 1 メッセージ 400 バイトに切り詰める (multibyte の欠けは iconv -c で除去)。
      # ツール出力の巨大な行がほとんどを占めるので、行数は多めに取る
      recent=$(tail -n 300 "$transcript" | ${pkgs.jq}/bin/jq -r '
          select(.type == "user" or .type == "assistant")
          | select(.isMeta != true)
          | .message.content
          | if type == "string" then .
            elif type == "array" then ([ .[] | select(.type == "text") | .text ] | join(" "))
            else empty end' 2>/dev/null \
        | grep -v -e '^[[:space:]]*$' -e '^<' \
        | tail -n 16 | cut -c 1-400 | iconv -f UTF-8 -t UTF-8 -c)
      [ -n "$recent" ] || exit 0

      prev=$(tmux show-options -pqv -t "$TMUX_PANE" @claude_topic)
      inst="以下は開発セッションの直近の会話ログ。今の話題を表す短い日本語ラベル(15文字以内)だけを1行で出力して。説明文・謝罪・エラー報告は出力しない。"
      if [ -n "$prev" ]; then
        inst="$inst 現在のラベルは「$prev」。話題が実質変わっていなければ現在のラベルをそのまま出力して。"
      fi

      title=$(printf '%s\n' "$recent" \
        | CLAUDE_TMUX_TOPIC_INNER=1 timeout 60 claude -p --model haiku "$inst" \
        | tr -d '\n"`' | head -c 72 | iconv -f UTF-8 -t UTF-8 -c)

      # ラベルとして異常な出力は捨てて据え置く (次の周期で自己回復する):
      # claude -p のエラー文 / 句点入りの説明文 / 長すぎる出力 (>60 バイト ≈ 20 文字)
      case "$title" in
        *"Execution error"* | *"API Error"* | *。*) exit 0 ;;
      esac
      [ -n "$title" ] && [ "''${#title}" -le 60 ] || exit 0

      [ "$title" != "$prev" ] || exit 0
      tmux set-option -p -t "$TMUX_PANE" @claude_topic "$title"
      exit 0
    fi

    # ここから Stop フック本体。stdin にフックの JSON が来る
    transcript=$(${pkgs.jq}/bin/jq -r '.transcript_path // empty')
    [ -n "$transcript" ] && [ -f "$transcript" ] || exit 0

    # ペイン単位で 5 分スロットリング
    now=$(date +%s)
    last=$(cat "$stamp" 2>/dev/null || echo 0)
    [ $((now - last)) -ge 300 ] || exit 0
    printf '%s' "$now" >"$stamp"

    # ターン終了をブロックしないようワーカーを切り離して起動
    setsid="${setsidBin}"
    if [ -n "$setsid" ]; then
      "$setsid" "$0" worker "$transcript" </dev/null >/dev/null 2>&1 &
    else
      ( "$0" worker "$transcript" </dev/null >/dev/null 2>&1 & )
    fi
  '';

  # settings.json に足す hooks 設定。コマンドは PATH 解決 (home.packages で入る)
  # なので nix store パスを settings.json に焼き込まない
  hooksJson = pkgs.writeText "claude-hooks.json" (
    builtins.toJSON {
      hooks = {
        Stop = [
          {
            hooks = [
              {
                type = "command";
                command = "claude-tmux-topic";
              }
            ];
          }
        ];
        SessionStart = [
          {
            hooks = [
              {
                type = "command";
                command = "claude-tmux-topic reset";
              }
            ];
          }
        ];
      };
    }
  );

  # ~/.claude/settings.json は Claude Code 自身も書き換える (permission の追記等)
  # ため home.file で symlink 化できない。switch のたびに hooks キーだけ deep merge する
  mergeSettings = pkgs.writeShellScript "claude-merge-settings" ''
    set -eu
    settings="$HOME/.claude/settings.json"
    if [ -f "$settings" ]; then
      tmp="$settings.tmp"
      ${pkgs.jq}/bin/jq -s '.[0] * .[1]' "$settings" ${hooksJson} >"$tmp"
      mv "$tmp" "$settings"
    else
      install -D -m 644 ${hooksJson} "$settings"
    fi
  '';
in
{
  home.packages = [
    pkgs-master.claude-code
    claude-tmux-topic
  ];

  home.activation.claudeSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run ${mergeSettings}
  '';
}
