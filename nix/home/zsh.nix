{ pkgs, lib, ... }:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;

    # 履歴からのゴースト補完。表示された候補は → / End で確定できる。
    autosuggestion.enable = true;
    # 打ちながらコマンドの正誤・引用符の対応が色で分かる。zsh-abbr の展開とも共存する。
    syntaxHighlighting.enable = true;

    # タブ補完を fzf のインタラクティブ選択に置換する。compinit の後・
    # syntax-highlighting の前に読み込む必要があり、home-manager の plugins は
    # その位置に差し込まれる。プレビュー設定は initContent 側の zstyle で行う。
    plugins = [
      {
        name = "fzf-tab";
        src = pkgs.zsh-fzf-tab;
        file = "share/fzf-tab/fzf-tab.plugin.zsh";
      }
    ];

    # alias ではなく abbr で短縮する。Space/Enter で完全形に展開されるので、
    # 実行前に本当のコマンドが見える・履歴に完全形で残る・コマンドを覚えられる。
    zsh-abbr = {
      enable = true;
      abbreviations = {
        vim = "nvim";
        vi = "nvim";
        v = "nvim";

        c = "clear";
        # ls は eza に寄せる。アイコン・git status・ツリーが出る。
        l = "eza -lah --icons --git";
        ls = "eza --icons";
        lt = "eza --tree --level=2 --icons";
        # cat は bat（シンタックスハイライト付き）。-pp で装飾なし素の表示。
        cat = "bat -pp";

        # モダン置換。abbr なので展開後の完全形が実行前に見える＝元コマンドの
        # フラグ差（dust/duf/btop は流儀が違う）に気づける。ps/sed は差が大きいので張らない。
        du = "dust";
        df = "duf";
        top = "btop";

        gs = "git status";
        gl = "git log --oneline --graph --decorate --all";

        # ドットの数だけ親階層を遡る。.. は auto_cd で足りるが、
        # 複数階層を一度に上がれるよう ... 以降を用意する。
        ".." = "cd ..";
        "..." = "cd ../..";
        "...." = "cd ../../..";
        "....." = "cd ../../../..";
      };
    };

    initContent = lib.mkMerge [
      ''
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

        # ---- fzf-tab ----
        # 標準の補完メニューは切って fzf-tab に任せる。
        zstyle ':completion:*' menu no
        # cd 補完はディレクトリ中身を eza でプレビュー。
        zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1a --icons --color=always $realpath'
        # グループが複数あるときは `<` `>` で切り替え、`/` で候補内を絞り込む。
        zstyle ':fzf-tab:*' switch-group '<' '>'
        zstyle ':fzf-tab:*' fzf-flags --height=60% --border

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
      ''

      # fzf 統合も atuin も Ctrl-R を bind するため、最後（mkAfter）に atuin へ確定させる。
      # 上矢印は --disable-up-arrow で zsh 標準のまま残している。
      (lib.mkAfter ''
        bindkey '^r' atuin-search
      '')
    ];
  };
}
