# 7110 dotfiles

## TODO
- [ ] zshrcをnixネイティブで書くか悩んでいるので、いつか決めてなおす。今は手動シンボリック貼ってる...
- [ ] homeに直がきしたgitの設定を移行してimportしたい..
- [ ] neovimのlspとnixの言語サーバーを連携

## Usage
### nix
```sh
sudo darwin-rebuild switch --flake .#7110
```

### devShells
- node (LTS)
```sh
nix flake init -t github:naito-7110/dotfiles#node
```

## Docs
- [Neovim](./docs/neovim.md)
- [AeroSpace](./docs/aerospace.md)

## WSL (Ubuntu) での home-manager セットアップ
standalone home-manager 構成 (`homeConfigurations."naito-7110@wsl"`) を使う。

### 1. Nix をインストール
Determinate Systems のインストーラ推奨（systemd / `nix.conf` を整えてくれる）。
```sh
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install linux
```
公式インストーラを使う場合は `~/.config/nix/nix.conf` に `experimental-features = nix-command flakes` を追加すること。

### 2. dotfiles を取得
```sh
git clone https://github.com/naito-7110/dotfiles ~/works/dotfiles
cd ~/works/dotfiles
```

### 3. 初回 switch
```sh
nix run home-manager/master -- switch --flake .#naito-7110@wsl
```
`username` / `homeDirectory` は `/home/naito-7110` 固定なので、WSL 側のユーザ名も `naito-7110` に揃えること（別名なら `flake.nix` の extraSpecialArgs を書き換える）。

### 4. 2 回目以降
```sh
home-manager switch --flake ~/works/dotfiles#naito-7110@wsl
```

### ハマりどころ
- zsh をログインシェルにするには `chsh -s $(which zsh)` を別途実行する。
- `/etc/wsl.conf` に `[boot] systemd=true` を入れておかないと nix-daemon が立たないことがある。
- `nvim-treesitter` のパーサーコンパイル用に `gcc` を `linux.nix` で入れている。
