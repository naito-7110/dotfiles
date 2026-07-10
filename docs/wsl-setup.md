# WSL 事前環境登録

このリポジトリ（standalone home-manager 構成 `homeConfigurations."naito-7110@wsl"`）を
WSL 上で適用できる状態にするまでの、**リポジトリ適用前**の環境準備を細かくまとめる。
ここまで済ませれば `home-manager switch --flake .#naito-7110@wsl` が通る。

適用そのもの（2 回目以降の switch・ハマりどころ）は
[README の WSL セクション](../README.md#wsl-ubuntu-での-home-manager-セットアップ) を参照。

> 表記: `PS>` は Windows の PowerShell（管理者）、`$` は WSL(Ubuntu) 内のシェルで実行する。

---

## 0. 前提とゴール
- Windows 10 (21H2 以降) / Windows 11
- ディストロは **Ubuntu**（22.04 / 24.04 系）を想定
- WSL 側のユーザ名は **`naito-7110`** に揃える
  - `username` / `homeDirectory = /home/naito-7110` が `flake.nix` の `hosts.wsl` で固定のため
  - 別名にするなら `flake.nix` の `hosts.wsl.username` / `homeDirectory` を書き換える

**この文書のゴール**: 下記 6 ステップを終えて、最後の「疎通確認」がすべて緑になること。

| # | やること | 完了の合図 |
|---|----------|------------|
| 1 | WSL2 + Ubuntu 導入 | `wsl -l -v` で Ubuntu が `VERSION 2` |
| 2 | systemd 有効化 | `systemctl is-system-running` が `running`/`degraded` |
| 3 | apt で下ごしらえ | `git --version` / `curl --version` が出る |
| 4 | git 認証手段の用意 | SSH 鍵 or `gh auth` のどちらか |
| 5 | Nix インストール | `nix --version` と flakes が動く |
| 6 | リポジトリ取得 | `~/works/dotfiles` に clone 済み |

---

## 1. Windows 側: WSL2 と Ubuntu を入れる
PowerShell を**管理者として**開き:

```powershell
PS> wsl --install -d Ubuntu
```

- 仮想化機能・WSL2 カーネル・Ubuntu まで一括で入る。**再起動を求められたら従う**。
- 再起動後に Ubuntu が自動起動し、初回セットアップに入る。

### 既に WSL がある場合
最新化と既定バージョンの固定だけしておく:

```powershell
PS> wsl --update
PS> wsl --set-default-version 2
PS> wsl --list --online          # 入れられるディストロ一覧
PS> wsl --install -d Ubuntu
```

### 初回のユーザ作成
Ubuntu の初回起動で UNIX ユーザ名とパスワードを聞かれる。

- **ユーザ名は必ず `naito-7110`**（`flake.nix` 固定のため。ここを外すと後で switch が
  `/home/<別名>` を掘って噛み合わない）。
- パスワードは `sudo` 用。忘れないもので可。

### バージョン確認
PowerShell 側で:

```powershell
PS> wsl -l -v
#   NAME      STATE           VERSION
# * Ubuntu    Running         2
```

`VERSION` が `2` であること。`1` なら `wsl --set-version Ubuntu 2` で上げる。

---

## 2. `/etc/wsl.conf` で systemd を有効化
Nix（Determinate インストーラ）は nix-daemon を **systemd サービス**として登録する。
systemd が無いと daemon が上がらず `nix` コマンドが「daemon に繋がらない」で落ちる。

WSL(Ubuntu) 内で `/etc/wsl.conf` を作る/編集する（要 `sudo`）:

```ini
[boot]
systemd=true

[interop]
appendWindowsPath=true
```

- `systemd=true` … これが本命。無効だと nix-daemon が立たないことがある。
- `appendWindowsPath=true` … Windows 側 PATH を引き継ぐ。`linux.nix` の `wslview` が
  `powershell.exe` をフルパス指定で呼ぶので必須ではないが、`explorer.exe` 等を
  素の名前で叩けるので有効にしておくと楽。

### 反映（重要）
`wsl.conf` は WSL インスタンスの起動時にしか読まれない。PowerShell 側で一度落とす:

```powershell
PS> wsl --shutdown
```

数秒待ってから Ubuntu を開き直す（`wsl --shutdown` 直後の即再起動は失敗しやすい）。

### 確認
```sh
$ systemctl is-system-running
# running          ← 理想
# degraded         ← 一部サービス失敗だが systemd 自体は起動、これも可
```

`Failed to connect to bus` や `offline` が出るなら systemd が有効になっていない。
`wsl.conf` の綴り（`sytemd` などのタイポ）と、`wsl --shutdown` を実際にかけたかを疑う。

---

## 3. 下ごしらえ（Ubuntu 側）
リポジトリ取得と Nix インストーラ実行に最低限必要なものだけ apt で入れる。

```sh
$ sudo apt update
$ sudo apt install -y git curl xz-utils ca-certificates
```

- `git` … リポジトリ取得
- `curl` … Nix インストーラのダウンロード
- `xz-utils` … Nix のバイナリ展開で使う（未導入環境で稀に不足する）
- `ca-certificates` … https の証明書検証

> `gcc` / `wl-clipboard` / `wslview` などリポジトリが必要とするパッケージは
> `nix/home/linux.nix` が home-manager 経由で入れる。**apt では入れない**
> （二重管理になり、どちらが効いているか分からなくなるため）。

確認:

```sh
$ git --version && curl --version | head -1
```

---

## 4. git アイデンティティと GitHub 認証
### アイデンティティは home-manager 管理（手動設定不要）
git の user.name / user.email は `nix/home/git.nix` で宣言され、値は
`flake.nix` の `hosts.wsl` から渡る。`~/.gitconfig` は home-manager が生成するので、
**`git config --global user.name` 等は打たない**（手打ちすると switch 後に上書き／競合する）。

### GitHub 認証だけは事前に用意する
clone と後々の push/API 用に、どちらか一方を用意しておく。

**A. SSH 鍵を使う場合**
- 鍵の生成と GitHub への公開鍵登録は**各自で行う**（このリポジトリでは `~/.ssh` 配下を管理しない）。
- clone URL は `git@github.com:...` 形式を使う。

**B. HTTPS + `gh` を使う場合**
- clone は https（後述）。認証は switch 後に `gh` が入ってから:
  ```sh
  $ gh auth login          # GitHub.com / HTTPS / ブラウザ認証
  ```

---

## 5. Nix をインストール
**Determinate Systems のインストーラを推奨。** systemd サービス登録・`nix.conf` の
`experimental-features`（flakes 有効化）・SELinux 対応まで面倒を見てくれる。

```sh
$ curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install linux
```

- 途中で「systemd を使うか」等を聞かれたら既定（Yes）で進める。
- インストールログの最後に「開き直すか `. .../nix-daemon.sh` を source しろ」と出る。

### PATH を通す
インストール直後の現行シェルには PATH が通っていない。**シェルを開き直す**か、明示的に source:

```sh
$ . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
```

### daemon が上がっているか確認
```sh
$ systemctl status nix-daemon --no-pager
# active (running) なら OK
```

`inactive`/`not found` の場合は systemd が有効か（ステップ 2）を再確認。手動起動は:

```sh
$ sudo systemctl enable --now nix-daemon
```

### flakes の疎通確認
```sh
$ nix --version                     # nix (Nix) 2.x が出る
$ nix flake --help >/dev/null && echo "flakes OK"
```

`experimental Nix feature 'nix-command' is disabled` 等が出たら flakes が無効。
Determinate 版なら通常は設定済みだが、公式インストーラを使った場合は自分で有効化する:

```sh
$ mkdir -p ~/.config/nix
$ printf 'experimental-features = nix-command flakes\n' >> ~/.config/nix/nix.conf
```

> **公式インストーラを使う場合**（Determinate を使わない選択）:
> ```sh
> $ sh <(curl -L https://nixos.org/nix/install) --daemon
> ```
> この場合 flakes 有効化（上の `nix.conf` 追記）は**必須**。

---

## 6. リポジトリを取得
ホームの `~/works/` 配下に置く（他の場所でも動くが、README/docs はこのパス前提で書く）。

```sh
$ mkdir -p ~/works
# HTTPS の場合
$ git clone https://github.com/naito-7110/dotfiles ~/works/dotfiles
# SSH の場合
$ git clone git@github.com:naito-7110/dotfiles ~/works/dotfiles

$ cd ~/works/dotfiles
```

---

## 疎通確認（ここまでの総点検）
```sh
$ wsl.exe -l -v 2>/dev/null | grep -i ubuntu   # (Win 側でも可) VERSION 2
$ systemctl is-system-running                  # running / degraded
$ git --version && curl --version | head -1    # 両方出る
$ nix --version                                # nix (Nix) 2.x
$ nix flake --help >/dev/null && echo flakes OK
$ test -f ~/works/dotfiles/flake.nix && echo repo OK
```

すべて緑なら**事前環境登録は完了**。

---

## これで初回適用へ
```sh
$ cd ~/works/dotfiles
$ nix run home-manager/master -- switch --flake .#naito-7110@wsl
```

- 初回はビルドで数分〜十数分かかる（`vue-language-server` のビルドなど重いものを含む）。
- 2 回目以降・ログインシェル切り替え（`chsh`）・その他ハマりどころは
  [README の WSL セクション](../README.md#wsl-ubuntu-での-home-manager-セットアップ) を参照。

---

## トラブルシューティング早見表
| 症状 | 原因 | 対処 |
|------|------|------|
| `nix: command not found`（インストール直後） | PATH 未反映 | シェルを開き直す or `nix-daemon.sh` を source |
| `error: could not connect to nix daemon` | nix-daemon 未起動 | `systemctl status nix-daemon` → `sudo systemctl enable --now nix-daemon` |
| `is disabled; use --extra-experimental-features` | flakes 無効 | `~/.config/nix/nix.conf` に `experimental-features = nix-command flakes` |
| `systemctl` が `Failed to connect to bus` | systemd 無効 | `wsl.conf` の `systemd=true` と `wsl --shutdown` を確認 |
| switch が `/home/<別名>` を掘る | ユーザ名不一致 | ユーザ名を `naito-7110` にする or `flake.nix` の `hosts.wsl` を修正 |
| clone で認証失敗 | 認証手段未用意 | ステップ 4（SSH 鍵 or `gh auth`）をやり直す |

## チェックリスト
- [ ] `wsl --install -d Ubuntu` 済み、`wsl -l -v` が VERSION 2、ユーザ名 `naito-7110`
- [ ] `/etc/wsl.conf` に `systemd=true`、`wsl --shutdown` で反映、`systemctl` が動く
- [ ] `git` / `curl` / `xz-utils` / `ca-certificates` を apt で導入
- [ ] GitHub 認証手段（SSH 鍵 or `gh`）を用意
- [ ] Nix インストール済み、`nix-daemon` active、`nix flake` が動く
- [ ] `~/works/dotfiles` を clone 済み
