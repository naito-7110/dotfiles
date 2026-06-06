
{ ... }:

{
  programs.git = {
    enable = true;

    delta = {
      enable = true;
      options = {
        navigate = true;
        line-numbers = true;
      };
    };

    settings = {
      user = {
        name = "naito-7110";
        email = "shige.7110.330@gmail.com";
      };

        core = {
        editor = "nvim -f";
        autocrlf = "input";
        quotepath = false;
      };

      commit.verbose = true;

      color.status = {
        added = "green";
        changed = "red";
        untracked = "yellow";
        unmerged = "magenta";
      };

      pull.rebase = true;
      fetch.prune = true;

      push = {
        default = "current";
        autoSetupRemote = true;
      };

      rebase.autostash = true;

      status.showUntrackedFiles = "all";

      init.defaultBranch = "main";

      diff = {
        colorMoved = "default";
      };
    };
  };
}
