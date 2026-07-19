# Cornix キーマップ同期コマンド。repo の .vil (keyboards/cornix/) と実機を
# vitaly (VIA/Vial CLI) で push / pull / diff する。
{
  writeShellApplication,
  vitaly,
  jq,
  diffutils,
}:
writeShellApplication {
  name = "cornix";
  runtimeInputs = [
    vitaly
    jq
    diffutils
  ];
  text = ''
    usage() {
      cat <<'EOF'
    使い方: cornix <devices|diff|pull|push> [macos|wsl]

      devices  接続中の VIA/Vial デバイスを一覧表示
      diff     repo の .vil と実機キーマップの差分を表示
      pull     実機キーマップを repo の .vil に吸い出す
      push     repo の .vil を実機に書き込む(差分表示 → y/N 確認)

    対象 .vil は省略時 OS で自動選択 (macOS→macos.vil, Linux→wsl.vil)。
    置き場所は $CORNIX_KEYMAP_DIR (既定: ~/works/dotfiles/keyboards/cornix)。
    EOF
    }

    cmd="''${1:-}"
    case "$cmd" in
      devices | diff | pull | push) ;;
      -h | --help)
        usage
        exit 0
        ;;
      *)
        usage >&2
        exit 1
        ;;
    esac

    if [ "$cmd" = devices ]; then
      exec vitaly devices
    fi

    target="''${2:-}"
    if [ -z "$target" ]; then
      case "$(uname -s)" in
        Darwin) target=macos ;;
        *) target=wsl ;;
      esac
    fi
    case "$target" in
      macos | wsl) ;;
      *)
        echo "不明なターゲット: $target (macos か wsl を指定)" >&2
        exit 1
        ;;
    esac

    dir="''${CORNIX_KEYMAP_DIR:-$HOME/works/dotfiles/keyboards/cornix}"
    file="$dir/$target.vil"
    if [ ! -f "$file" ]; then
      echo "キーマップが見つかりません: $file" >&2
      exit 1
    fi

    tmp="$(mktemp -t cornix.XXXXXX)"
    trap 'rm -f "$tmp"' EXIT

    # 実機から現在のキーマップを吸い出す。Cornix は ProductID 0x1 (VendorID は
    # vitaly で指定できないため PID で選択)。失敗や空出力はデバイス未検出扱い。
    fetch() {
      if ! vitaly -i 1 save -f "$tmp" >/dev/null || ! jq -e . "$tmp" >/dev/null 2>&1; then
        echo "Cornix が見つかりません。USB で接続して再実行してください(BLE では見えないことがあります)。" >&2
        exit 1
      fi
    }

    # jq -S でキー順を正規化してから比較する (GUI エクスポートと vitaly save の
    # 出力順の違いを差分扱いしないため)
    keymap_diff() {
      diff -u --label "repo:$target.vil" --label keyboard \
        <(jq -S . "$file") <(jq -S . "$tmp")
    }

    case "$cmd" in
      diff)
        fetch
        if keymap_diff; then
          echo "差分なし: 実機と $target.vil は一致しています"
        fi
        ;;
      pull)
        fetch
        mv "$tmp" "$file"
        trap - EXIT
        echo "実機のキーマップを $file に保存しました (差分は git diff で確認)"
        ;;
      push)
        fetch
        if keymap_diff; then
          echo "差分なし: 書き込みは不要です"
          exit 0
        fi
        printf '%s' "$target.vil を実機に書き込みますか? [y/N] "
        read -r answer
        case "$answer" in
          y | Y)
            vitaly -i 1 load -f "$file"
            echo "書き込み完了"
            ;;
          *) echo "中止しました" ;;
        esac
        ;;
    esac
  '';
}
