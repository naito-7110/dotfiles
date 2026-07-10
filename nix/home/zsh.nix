{ ... }:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;

    shellAliases = {
      vim = "nvim";
      vi = "nvim";
      v = "nvim";

      c = "clear";
      l = "ls -lah";

      gs = "git status";
      gl = "git log --oneline --graph --decorate --all";
    };

    initContent = ''
      # ---- history ----
      setopt hist_ignore_all_dups
      setopt hist_ignore_dups
      setopt hist_reduce_blanks
      setopt append_history
      setopt share_history
      setopt inc_append_history
      HISTFILE=$HOME/.zsh_history
      HISTSIZE=10000
      SAVEHIST=10000

      # --- options
      setopt auto_cd

      # zoxide の doctor は「自分の init が zshrc の最後じゃない」と警告するが、
      # home-manager は starship 等の integration を宣言的に後段へ並べるため
      # 順序が前後するだけで実害はない。宣言構成では誤検知なので無効化する。
      export _ZO_DOCTOR=0

      # ---- mp4 → gif ----
      # 使い方: mp4gif <入力.mp4> [幅=640] [fps=12] [速度=1]
      #   例: mp4gif demo.mp4            → 640幅 / 12fps / 等速
      #       mp4gif demo.mp4 960 15 1.5 → 960幅 / 15fps / 1.5倍速
      # パレット生成方式で減色するので画質を保ったまま小さくできる。
      mp4gif() {
        local in=$1
        if [[ -z $in ]]; then
          echo "usage: mp4gif <input.mp4> [width=640] [fps=12] [speed=1]" >&2
          return 1
        fi
        local w=''${2:-640} fps=''${3:-12} speed=''${4:-1}
        local out=''${in:r}.gif
        local palette; palette=$(mktemp --suffix=.png) || return 1
        local vf="setpts=PTS/$speed,fps=$fps,scale=$w:-1:flags=lanczos"
        ffmpeg -y -i "$in" -vf "$vf,palettegen" "$palette" 2>/dev/null &&
          ffmpeg -y -i "$in" -i "$palette" -lavfi "$vf [x]; [x][1:v] paletteuse" "$out" 2>/dev/null &&
          echo "$out ($(du -h "$out" | cut -f1))"
        local rc=$?
        rm -f "$palette"
        return $rc
      }
    '';
  };
}
