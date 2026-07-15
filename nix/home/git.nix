{ gitUserName, gitUserEmail, ... }:

{
  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      navigate = true;
      line-numbers = true;
    };
  };

  programs.git = {
    enable = true;

    settings = {
      user = {
        name = gitUserName;
        email = gitUserEmail;
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

      # 一度解決したコンフリクトを記録し、同じものが再出現したら自動で再適用する。
      # rebase をやり直すたびに同じコンフリクトを解き直す手間が消える。
      rerere.enabled = true;

      # コンフリクトマーカーに「共通の元コード」も併記する（<<< ||| === >>>）。
      # 両者が元をどう変えたか分かり、マージ判断がしやすい。
      merge.conflictStyle = "zdiff3";

      push = {
        default = "current";
        autoSetupRemote = true;
      };

      rebase.autostash = true;

      status.showUntrackedFiles = "all";

      init.defaultBranch = "main";

      diff = {
        colorMoved = "default";
        # 関数の増減などで差分がズレて表示されるのを抑え、読みやすい塊で出す。
        algorithm = "histogram";
      };
    };
  };
}
