{ pkgs, ... }:
{
  # Nix 本体 (デーモン / nix.conf) は Determinate Nix が管理するため、
  # nix-darwin 側の Nix 管理は無効化する（両 Mac とも Determinate インストーラ）。
  # flakes 等の experimental-features も Determinate 側の nix.conf が有効化済み。
  nix.enable = false;

  environment.systemPackages = with pkgs; [
    wezterm
    raycast
    # Slack は nix store が読み取り専用なので自前の自動更新が効かない。
    # nixpkgs 側の bump + rebuild で追従する。サーバに古い版を蹴られて
    # 待てない場合は pkgs-master.slack に一時的に逃がす（claude-code と同じ手）。
    slack
    # Windows 風の Alt+Tab ウィンドウ切り替え (トリガーは GUI で Option+Tab に設定)。
    # 初回にアクセシビリティ + 画面収録の TCC 許可が必要。nixpkgs 更新でパスが
    # 変わると再許可を求められることがある。
    alt-tab-macos
  ];

  programs.zsh.enable = true;
  system.primaryUser = "n7110";
  system.stateVersion = 4;
}
