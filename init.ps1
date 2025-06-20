$gitRepository = "https://github.com/naito-7110/dotfiles"

$userprofile = $env:USERPROFILE

$entryDir = "$userprofile\environments"
$githubDir = "$entryDir\github"
$workDir = "$githubDir\work"

$directories = @(
    $entry,
    $githubDir,
    $workDir,
    "$githubDir\rsi\internal",
    "$githubDir\rsi\external",
    "$entryDir\gitlab\external",
    "$entryDir\gitlab\internal"
)

# ディレクトリ構造の初期セットアップ
function ConstructDirectories() {
    foreach ($dir in $directories) {
        Write-Host $dir
        # if (-not (Test-Path $dir)) {
        #     New-Item -ItemType Directory -Path $dir | Out-Null
        # }
    }
}

function SetupScoop {
    if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
        Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
        Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
    }

    # extras バケットを追加（すでにあってもエラーにならない）
    scoop bucket add extras 2>$null

    if(-not (Get-Command git -ErrorAction SilentlyContinue)) {
        scoop install git
    }
}

function GitCloneDotfiles() {
    if(-not (Test-Path "$workDir\dotfiles")) {
        Write-Host "git clone $gitRepository $workDir\dotfiles"
        # git clone $gitRepository "$workDir/dotfiles"
    }
}

ConstructDirectories
SetupScoop
GitCloneDotfiles



