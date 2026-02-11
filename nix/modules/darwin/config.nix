{ pkgs, ... }:
{
   nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];


  environment.systemPackages = with pkgs; [
    wezterm
  ];

  programs.zsh.enable = true;
  system.stateVersion = 4;
}
