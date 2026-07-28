# C# devShell Template

`dotnet` SDK + roslyn-ls (Neovim の C# LSP)。

## Usage
```sh
direnv allow
```

VB.NET も混ざるソリューション（`.vbproj` を含む）は `dotnet` テンプレートを使う。
roslyn-ls は C# 専用で VB を扱えないため、VB 側は「ビルド → quickfix」で型チェックする。
