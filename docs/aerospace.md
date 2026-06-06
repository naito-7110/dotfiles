# AeroSpace

[AeroSpace](https://github.com/nikitabobko/AeroSpace) は macOS 向けの i3 ライクな
タイリングウィンドウマネージャ。SIP 無効化不要で動く。

## インストール
`nix/modules/darwin/aerospace.nix` の `services.aerospace` で管理。`darwin-rebuild`
時に launchd agent (`gui/<uid>/org.nix-community.home.aerospace`) も自動登録され、
ログイン時に起動する。

```sh
sudo darwin-rebuild switch --flake .#7110
```

## キーバインド
Option (`alt`) を modifier に i3 風。Service mode は `alt-shift-;` で入り、`esc`
で抜ける。

### Main mode
| Key | Action |
|-----|--------|
| `alt-h` / `j` / `k` / `l` | フォーカス移動 (左下上右) |
| `alt-shift-h` / `j` / `k` / `l` | ウィンドウ移動 |
| `alt-1` ~ `alt-9` | ワークスペース切り替え |
| `alt-shift-1` ~ `alt-shift-9` | 現在ウィンドウをワークスペースへ送る |
| `alt-tab` | 直前のワークスペースへ戻る |
| `alt-shift-tab` | 現ワークスペースを次のモニタへ |
| `alt-slash` | tiles レイアウト (横/縦トグル) |
| `alt-comma` | accordion レイアウト |
| `alt-minus` / `alt-equal` | リサイズ |
| `alt-shift-;` | service mode に入る |

### Service mode
| Key | Action |
|-----|--------|
| `esc` | 設定を再読み込みして main mode に戻る |
| `r` | ワークスペースのツリーをフラット化 |
| `f` | floating / tiling トグル |
| `backspace` | フォーカス以外のウィンドウを閉じる |

## 設定変更
`nix/modules/darwin/aerospace.nix` の `services.aerospace.settings` を書き換え → `darwin-rebuild switch`。
launchd agent が再ロードされて設定が即反映される。

実体の TOML は `/etc/aerospace.toml` 配下に生成される (確認用)。

## 起動・停止
```sh
# 状態確認
launchctl print "gui/$(id -u)/org.nix-community.home.aerospace"

# 手動再起動
launchctl kickstart -k "gui/$(id -u)/org.nix-community.home.aerospace"
```

## 動作確認 CLI
```sh
aerospace list-workspaces --all
aerospace list-windows --all
aerospace workspace 2          # ワークスペース 2 へ切替
aerospace reload-config        # 設定再読込
```

## トラブルシュート
- キーバインドが効かない → System Settings → Privacy & Security → Accessibility
  で AeroSpace を許可
- 一部アプリ (System Settings, Finder ダイアログ等) が無理矢理タイルされる
  → `on-window-detected` ルールで `layout floating` を当てる
- IME (Option キー入力) と衝突する場合 → 該当バインドだけ `cmd` 系に逃がす
