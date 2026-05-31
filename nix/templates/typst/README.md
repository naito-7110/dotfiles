# Typst devShell Template

執筆用の Typst 環境。`typst` コンパイラ、`tinymist` (LSP)、`typstyle` (formatter) を含む。

## Usage
```sh
direnv allow
typst watch main.typ
```

## 共同執筆 (git)

差分が読みやすいよう **1文1行** で書く。句点 `。` で改行し、段落の切れ目は空行を入れる。

```typst
これは1文目。
これは2文目で、少し長くても1行にまとめる。

ここから新しい段落。
```

PDF はビルド成果物なのでコミットせず、必要なら CI で `typst compile` して artifact に上げる。
