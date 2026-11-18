# Security scan devShell Template

外部公開資産の脆弱性スキャン用。WSL2 + Nix で動かす前提。

## Usage
```sh
direnv allow
nuclei -update-templates   # 初回のみ (.nuclei-templates に入る)
```

| 同梱 | 用途 |
|------|------|
| `nmap` | ポート・サービス探索 |
| `nuclei` | テンプレートベースの脆弱性スキャン |
| `testssl` | TLS 設定の診断 |
| `zap` | Web アプリの動的スキャン (unfree) |
| `libxslt` | nmap XML → HTML (`xsltproc`) |
| `jq` / `yq-go` | 結果・設定ファイルの加工 |
| `python3` (+ pyyaml, markdown, weasyprint) | レポートの PDF 生成 |

## 規約

- **対象情報・結果はコミットしない。** `projects/<名前>/` に対象ごとに置く
  (`.gitignore` 済み)。
- `./scripts` は PATH に通る。自前のスキャン手順はここに置く。
- 使い分けたい環境変数 (`PROJECT` など) は `.envrc.local` に書く (`.gitignore` 済み)。
- `NUCLEI_TEMPLATES_DIR` は `.nuclei-templates`、zap のホームは `.zap-home` (どちらも ignore 済み)。
- weasyprint が日本語を出せるよう、shellHook で Noto CJK だけの fontconfig を
  `FONTCONFIG_FILE` に向けている。

**認可された対象にだけ撃つこと。** スコープ外へのスキャンは事故のもと。
