{ ... }:
{
  programs.lazygit = {
    enable = true;
    settings = {
      git.pagers = [
        { pager = "delta --paging=never --dark"; }
      ];
    };
  };
}
