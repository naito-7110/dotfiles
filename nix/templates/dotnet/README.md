# dotnet devShell Template (C# / VB.NET)

## Usage
```sh
direnv allow
```

| 同梱 | 用途 |
|------|------|
| `dotnetCorePackages.sdk_10_0` | `dotnet build` / `dotnet test`（C# も VB も同じコンパイラ基盤） |
| `roslyn-ls` | **C# のみ**の LSP |
| `ilspycmd` | 参照 DLL のデコンパイル（API 参照用） |

C# だけのプロジェクトは `csharp` テンプレートで足りる。VB.NET (`.vbproj`) が
混ざるならこちらを使う。

## VB.NET の扱い

**nixpkgs の LSP はどれも VB を扱えない。** roslyn-ls / omnisharp-roslyn はいずれも
Roslyn の C# 側だけを載せており `Microsoft.CodeAnalysis.VisualBasic.*` を持たない
（omnisharp は `.vb` を開いても補完ゼロ、`.vbproj` をロードしようともしない）。
VS Code の C# 拡張も同じ。

VB 専用の LSP としては
[vb-ls](https://github.com/CoolCoderSuper/visualbasic-language-server)（Roslyn ベース）が
存在するが nixpkgs 未収録で、使うなら dotnet tool として持ち込む必要がある。

LSP の有無にかかわらず、この構成では型チェックをビルドで行う。サーバー側が
受け付ける言語バージョンの確認はコンパイラでしかできないため、この経路は常に要る。

1. **型チェックはビルドで行う。** devShell に入っていれば Neovim の
   `<leader>bb`（`:DotnetBuild`）が `dotnet build` を走らせ、
   `Foo.vb(20,32): error BC30456: ...` を quickfix に載せる。
   `:cnext` / `:cprev` で該当行へ飛べる
2. **API 参照はデコンパイル結果を grep する。** 補完が出ない分、
   実物のシグネチャをソースとして読む

```sh
ilspycmd -p -o reference/decompiled/<Name> libs/<Name>.dll
grep -rn "class FormScript" reference/decompiled/
```

3. シンタックスハイライトは Neovim 同梱の `syntax/vb.vim`（VB6 世代）＋
   dotfiles 側の `after/syntax/vb.vim`（VB.NET キーワードの追加）で効く

## 注意

`dotnet` が PATH に無い状態（devShell 外）から `:DotnetBuild` を呼ぶと
`nix develop --command dotnet build` にフォールバックするが、nix の評価で
毎回待たされる。**devShell に入って使うのが前提。**
