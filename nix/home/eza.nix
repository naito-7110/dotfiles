{ pkgs, ... }:
{
  # ls 置換の eza。abbr（l/ls/lt）は zsh.nix 側で定義する。
  # 既定配色が派手なので theme.yml で色を抑える（実体は .config/eza/theme.yml）。
  # programs.eza の shell 連携は ls 等の alias を張ってしまい abbr 方針と衝突するので使わない。
  home = {
    packages = [ pkgs.eza ];
    file.".config/eza/theme.yml".source = ../../.config/eza/theme.yml;
  };
}
