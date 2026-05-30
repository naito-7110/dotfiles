# Neovim

## Plugin manager
[lazy.nvim](https://github.com/folke/lazy.nvim) が `.config/nvim/lua/config/plugins.lua` で自動ブートストラップされる。初回起動時にプラグイン一式インストール。

## LSP
言語サーバは devShell または system 側で提供:

| Lang | Server | 提供元 |
|------|--------|--------|
| C# | roslyn-ls | dotnet devShell |
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

## DAP (Debugger)
Rust / C# のデバッガが devShell に同梱されている。

| Lang | Adapter | nixpkgs |
|------|---------|---------|
| Rust | lldb-dap | `lldb` |
| C# | netcoredbg | `netcoredbg` |

### 使い方
1. 該当言語の devShell で `direnv allow` または `nix develop`
2. Neovim 起動 → lazy.nvim が `nvim-dap` / `dap-ui` / `dap-virtual-text` を自動インストール
3. ビルド (`cargo build` / `dotnet build`) 後、`<leader>dc` で起動。実行ファイルパスを聞かれる
   - Rust: `target/debug/<bin>`
   - C#: `bin/Debug/<tfm>/<app>.dll`

### Keymaps
| Key | Action |
|-----|--------|
| `<leader>du` | UI toggle |
| `<leader>dc` | continue / start |
| `<leader>db` | breakpoint toggle |
| `<leader>do` / `di` / `dO` | step over / into / out |
| `<leader>dr` | REPL toggle |

### トラブルシュート
- アダプタが見つからない → `which lldb-dap` / `which netcoredbg` で PATH 確認、devShell に入り直す
- ログ確認 → Neovim 内で `:DapShowLog`
