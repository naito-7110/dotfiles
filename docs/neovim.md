# Neovim

## Plugin manager
[lazy.nvim](https://github.com/folke/lazy.nvim) が `.config/nvim/lua/config/plugins.lua` で自動ブートストラップされる。初回起動時にプラグイン一式インストール。

## LSP
言語サーバは devShell または system 側で提供:

| Lang | Server | 提供元 |
|------|--------|--------|
| C# | roslyn-ls | dotnet / csharp devShell |
| VB.NET | vb-ls | dotnet devShell (nixpkgs 未収録のため[自前パッケージング](#vbnet-の-lsp-vb_ls)) |
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

### VB.NET の LSP (vb_ls)
**nixpkgs には VB を扱える LSP が無い。** roslyn-ls も omnisharp-roslyn も Roslyn の
C# 側だけを載せており `Microsoft.CodeAnalysis.VisualBasic.*` を同梱していない
(omnisharp は `.vb` を開いても補完ゼロ、`.vbproj` をロードしようともしない)。

代わりに **[vb-ls](https://github.com/CoolCoderSuper/visualbasic-language-server) 0.4.0** を
`nix/templates/dotnet` の devShell で自前パッケージングして使う。中身は
`Microsoft.CodeAnalysis.LanguageServer` (VS Code の C# 拡張や nixpkgs roslyn-ls と同じ
公式 Roslyn LSP) に **VB の Roslyn アセンブリを同梱し直したもの**。だから roslyn_ls と
同じ流儀で動く。net10.0 ターゲットなので SDK 10 でそのまま走る。

実測 (Infor SyteLine の実物フォームスクリプト 1,346行に対して):
`ThisForm.` で **68件の実 Mongoose API 補完**、`Inherits FormScript` のホバーが
`Class Mongoose.Scripting.FormScript` を解決、`ThisForm.NoSuchMethod()` が
**保存前に** `BC30456 'NoSuchMethod' is not a member of 'IWSForm'` として出る。

#### 実装上のハマりどころ 2点
1. **このサーバは rootUri からプロジェクトを自動で開かない。** `initialize` 後に
   カスタム通知 `solution/open` を送るまで、接続はできても補完・ホバーが
   まるごとゼロのまま (構文解析ベースの IDExxxx 診断だけが出るので気付きにくい)。
   `lua/config/lsp.lua` の `on_attach` で送っている。
   C# 側は nvim-lspconfig が同じことをやってくれるので roslyn_ls には不要。
2. **`root_markers` はグロブを解決しない。** `{ "*.slnx" }` を渡すと `root_dir` が
   `nil` になり 1 に落ちる。`root_dir` を関数にして上方向探索している。
3. **nixpkgs 未収録なので更新は手動。** テンプレートの `flake.nix` で NuGet の
   nupkg をハッシュ固定して展開している。上げるときは version と hash を両方直す:
   `nix store prefetch-file https://www.nuget.org/api/v2/package/vb-ls/<新版>`
   (nixpkgs に入ったらこの derivation は消してよい)

### ビルド → quickfix
LSP とは別に、コンパイラを直接叩く経路も用意してある。**LSP があっても消さない** —
サーバー側 (Infor テナント等) が受け付ける言語バージョンの確認や、ソリューション全体の
最終確認はコンパイラでしかできない。

| Key | Action |
|-----|--------|
| `<leader>bb` | `:DotnetBuild` — ビルド → quickfix (`:cnext` / `:cprev` で該当行へ) |

- ビルド対象はバッファに一番近い `*.vbproj` / `*.csproj`、無ければ `*.slnx` / `*.sln`
- **devShell に入って使う前提。** `dotnet` が PATH に無い場合は
  `nix develop --command` にフォールバックするが nix の評価で毎回待たされる
- auto-save と併用すると保存ごとにビルドが走るため、自動実行はしていない
- 診断の形をしていない失敗 (restore エラー等) は生ログを quickfix に出す
- MSBuild の差分ビルドの都合で、変更なしで再実行すると**警告は消える** (コンパイル自体が
  スキップされるため)。エラーは出力が生成されないので毎回出る

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
各言語のデバッガは devShell に同梱されている。C#/VB.NET (netcoredbg) は
Linux のみ — macOS arm64 では署名・entitlement の制約で nvim-dap から
動かせないため、macOS でブレークポイントが要る場合は VSCode を使う。

| Lang | Adapter | nixpkgs | 備考 |
|------|---------|---------|------|
| Rust | lldb-dap | `lldb` | |
| C# / VB.NET | netcoredbg | `netcoredbg` | Linux のみ |

### 使い方
1. 該当言語の devShell で `direnv allow` または `nix develop`
2. Neovim 起動 → lazy.nvim が `nvim-dap` / `dap-ui` / `dap-virtual-text` を自動インストール
3. Rust: `cargo build` 後、`<leader>dc` で起動。実行ファイルパス (`target/debug/<bin>`) を聞かれる
4. .NET: `dotnet build` (Debug 構成) 後、`<leader>dc` → `Launch DLL` を選び
   `bin/Debug/net10.0/<App>.dll` を指定。実行中プロセスには `Attach` を選んでアタッチ。
   Release ビルドや publish 済みバイナリにはブレークポイントが刺さらない

### Keymaps
| Key | Action |
|-----|--------|
| `<leader>du` | UI toggle |
| `<leader>dc` | continue / start |
| `<leader>db` | breakpoint toggle |
| `<leader>do` / `di` / `dO` | step over / into / out |
| `<leader>dr` | REPL toggle |
| `<leader>dq` | terminate |

### トラブルシュート
- アダプタが見つからない → `which lldb-dap` で PATH 確認、devShell に入り直す
- ログ確認 → Neovim 内で `:DapShowLog`
