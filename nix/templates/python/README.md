# Python devShell Template (uv)

## Usage
```sh
direnv allow
uv init            # pyproject.toml / .python-version を作る (初回のみ)
uv sync            # .venv を作って依存を入れる
uv add --dev debugpy   # デバッガを使うなら
```

| 同梱 | 用途 |
|------|------|
| `uv` | 依存解決・venv 管理・実行 (`uv run`) |
| `python313` | インタプリタ。uv にもこれを使わせる |
| `basedpyright` | LSP (型チェック・補完・定義ジャンプ) |
| `ruff` | LSP (lint) + フォーマッタ。Neovim の conform が保存時に呼ぶ |

パッケージは `pip` ではなく **uv で入れる**。`uv add <pkg>` が pyproject.toml と
`uv.lock` を更新し、`.venv` に反映する。実行は `uv run <cmd>` か、`.venv` を
有効化してから直接叩く。

## nix と uv の噛み合わせ

- **uv に Python を落とさせない。** uv は既定で python-build-standalone のビルド済み
  バイナリを取ってくるが、NixOS ではダイナミックリンカが合わず起動しない。
  この flake は `UV_PYTHON` を nixpkgs のインタプリタに固定し、
  `UV_PYTHON_DOWNLOADS=never` でダウンロードを禁止している。
- **venv は `.venv` 固定** (`UV_PROJECT_ENVIRONMENT`)。Neovim の LSP / DAP が
  このパスからインタプリタを解決するので、場所を変えるなら
  dotfiles の `.config/nvim/lua/config/python.lua` も直すこと。
- **manylinux wheel 対策**に `LD_LIBRARY_PATH` を通してある (Linux のみ)。
  これが無いと numpy 等の binary wheel が `libstdc++.so.6` を見つけられず
  import 時に落ちる。

## LSP

`basedpyright` と `ruff` の 2 枚を同時に上げる (Neovim 側の設定は dotfiles の
`.config/nvim/lua/config/lsp.lua`)。役割分担:

- basedpyright: 型・補完・ジャンプ。ホバーもこちら
- ruff: lint 診断とフォーマット。ホバーは無効化してある (basedpyright と二重に出るため)

basedpyright は既定の `typeCheckingMode` が `recommended` で、型注釈の無い
既存コードだと診断が壊滅的に出る。dotfiles 側では `standard` に落としてある。

## デバッグ

`uv add --dev debugpy` してから Neovim で `<leader>dc`。
アダプタは `.venv/bin/python -m debugpy.adapter` を使うので、
**debugpy は nix ではなくプロジェクトの venv に入れる**（デバッグ対象と同じ
インタプリタでないとブレークポイントが刺さらない）。
