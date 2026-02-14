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
- node@v25
```sh
nix flake init -t github:naito-7110/dotfiles#node25
```
