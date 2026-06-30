{ pkgs, ... }:
{
  # macOS (nix-darwin) 用のホーム設定。
  # 共通部分は common.nix に集約し、ここでは mac 固有の差分のみを足す。
  # username / homeDirectory は flake.nix の extraSpecialArgs から渡される。
  imports = [ ./common.nix ];

  home = {
    file.".config/wezterm".source = ../../.config/wezterm;

    packages = with pkgs; [
      docker
      vscode
      texliveFull
    ];
  };
}
