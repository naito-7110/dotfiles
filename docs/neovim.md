# Neovim

## Plugin manager
[lazy.nvim](https://github.com/folke/lazy.nvim) が `.config/nvim/lua/config/plugins.lua` で自動ブートストラップされる。初回起動時にプラグイン一式インストール。

## LSP
言語サーバは devShell または system 側で提供:

| Lang | Server | 提供元 |
|------|--------|--------|
| C# | roslyn-ls | dotnet / csharp devShell |
| VB.NET | (無し) | ビルド → quickfix で代替。[.NET](#net-c--vbnet) 参照 |
| Rust | rust-analyzer | rust devShell |
| TypeScript / Vue | ts_ls, vue_ls | node devShell |
| Lua | lua_ls | root devShell |
| Nix | nil | root devShell |
| Markdown | marksman | root devShell |
| JSON | jsonls | (要インストール) |

### Keymaps
| Key | Action |
|-----|--------|
| `gd` / `gD` | definition / declaration |
| `gr` | references |
| `gi` | implementation |
| `gh` | hover |
| `<leader>e` | show diagnostics (float) |
| `<leader>rn` | rename symbol |
| `<leader>ca` | code action |
| `[d` / `]d` | prev / next diagnostic |

## .NET (C# / VB.NET)

### VB に LSP が無い問題
nixpkgs の LSP はどれも VB を扱えない。roslyn-ls も omnisharp-roslyn も Roslyn の
C# 側だけを載せており `Microsoft.CodeAnalysis.VisualBasic.*` を同梱していない
(omnisharp は `.vb` を開いても補完ゼロ、`.vbproj` をロードしようともしない)。
VB 専用の [vb-ls](https://github.com/CoolCoderSuper/visualbasic-language-server) は
存在するが nixpkgs 未収録。

そこで `.vb` の型チェックはビルド出力を quickfix に流して行う
(`lua/commands/dotnet.lua`)。**LSP が入ってもこの経路は残す** — サーバー側が
受け付ける言語バージョンの確認はコンパイラでしかできない。

| Key | Action |
|-----|--------|
| `<leader>bb` | `:DotnetBuild` — ビルド → quickfix (`:cnext` / `:cprev` で該当行へ) |

- ビルド対象はバッファに一番近い `*.vbproj` / `*.csproj`、無ければ `*.slnx` / `*.sln`
- **devShell に入って使う前提。** `dotnet` が PATH に無い場合は
  `nix develop --command` にフォールバックするが nix の評価で毎回待たされる
- auto-save と併用すると保存ごとにビルドが走るため、自動実行はしていない
- 診断の形をしていない失敗 (restore エラー等) は生ログを quickfix に出す

### シンタックスハイライト
`.vb` は同梱の `syntax/vb.vim` で filetype `vb` として色が付くが、これは VB6 世代で
`Imports` / `Class` / `Inherits` / `Try` / `Of` などを知らない。
`after/syntax/vb.vim` で VB.NET のキーワードを補っている
(treesitter に VB グラマーは無い)。

## Markdown
| Plugin | 役割 |
|--------|------|
| img-clip.nvim | クリップボード画像の貼り付け (編集中ファイル基準の `assets/` に保存) |
| markdown-preview.nvim | ブラウザでライブプレビュー (WSL は wslview 経由で Windows ブラウザ) |
| render-markdown.nvim | エディタ内整形表示 (見出し・表・チェックボックス) |
| cmp-path | リンク記述時のファイルパス補完 |

リンク先への移動は marksman LSP の `gd` (`[text](path.md)` や wiki link 上で) か、素の `gf` が使える。

### Keymaps
| Key | Action |
|-----|--------|
| `p` | (markdown内) クリップボードが画像なら画像貼り付け、それ以外は通常ペースト |
| `<leader>mi` | クリップボードの画像を貼り付け (明示) |
| `<leader>mp` | ブラウザプレビュー toggle |
| `<leader>mr` | エディタ内レンダリング toggle |

### 依存
- WSL: `wl-clipboard` (画像ペースト) / `wslu` (ブラウザ起動) — nix/home/linux.nix で導入済み
- macOS: 画像ペーストに `pngpaste` 推奨 (未導入の場合 `osascript` フォールバック)

## DAP (Debugger)
Rust 用デバッガが devShell に同梱されている。C# (netcoredbg) は macOS arm64
で署名・entitlement の制約により nvim-dap から動作させるのが困難なため
非対応 (LSP のみ)。ブレークポイントが要る場合は VSCode を使う。

| Lang | Adapter | nixpkgs |
|------|---------|---------|
| Rust | lldb-dap | `lldb` |

### 使い方
1. 該当言語の devShell で `direnv allow` または `nix develop`
2. Neovim 起動 → lazy.nvim が `nvim-dap` / `dap-ui` / `dap-virtual-text` を自動インストール
3. `cargo build` 後、`<leader>dc` で起動。実行ファイルパス (`target/debug/<bin>`) を聞かれる

### Keymaps
| Key | Action |
|-----|--------|
| `<leader>du` | UI toggle |
| `<leader>dc` | continue / start |
| `<leader>db` | breakpoint toggle |
| `<leader>do` / `di` / `dO` | step over / into / out |
| `<leader>dr` | REPL toggle |

### トラブルシュート
- アダプタが見つからない → `which lldb-dap` で PATH 確認、devShell に入り直す
- ログ確認 → Neovim 内で `:DapShowLog`
