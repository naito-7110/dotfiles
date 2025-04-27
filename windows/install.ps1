#######################
#
#   setup 
#
#######################
Write-Host "###########################"
Write-Host "1. setup "
Write-Host "###########################"

$directories = @(
    "$HOME\environments",
    "$HOME\environments\private",
    "$HOME\environments\projects",
    "$HOME\environments\github",
    "$HOME\environments\github\work",
    "$HOME\environments\github\rsi",
    "$HOME\environments\gitlab"
)

foreach($directory in $directories) {
    if(-Not (Test-Path $directory)) {
        New-Item -ItemType Directory -Path $directory -Force | Out-Null
        Write-Host "$directory created"
    }
    else {
        Write-Host "$directory already exists"
    }
}

Set-ExecutionPolicy RemoteSigned -scope CurrentUser
invoke-Expression (New-Object System.Net.WebClient).DownloadString('https://get.scoop.sh')

scoop install scoop

#######################
#                      
#     git clone        
#                      
#######################
Write-Host "###########################"
Write-Host "2. git clone dotfiles..."
Write-Host "###########################"
if(-Not (Test-Path "$HOME\environments\github\work/dotfiles")) {
    git clone "https://github.com/naito-7110/dotfiles.git" "$HOME\environments\github\work/dotfiles"
}

#######################
#                      
#    link paths       
#                      
#######################
Write-Host "###########################"
Write-Host "3. link paths..."
Write-Host "###########################"

New-Item -ItemType Directory -Force -Path "$HOME\.config"
New-Item -ItemType SymbolicLink -Force -Name "$HOME\.config" -Target "$HOME\environments\github\work\dotfiles\windows/.config"
New-Item -ItemType SymbolicLink -Force -Name "$HOME\.gitconfig" -Target "$HOME\environments\github\work\dotfiles\windows/.gitconfig" 
New-Item -ItemType SymbolicLink -Force -Name "$HOME\environments\github\.gitconfig" -Target "$HOME\environments\github\work\dotfiles\windows/github.gitconfig" 
New-Item -ItemType SymbolicLink -Force -Name "$HOME\environments\gitlab\.gitconfig" -Target "$HOME\environments\github\work\dotfiles\windows/gitlab.gitconfig" 


#######################
#
#   Install Scoop
#
#######################
Write-Host "###########################"
Write-Host "4. install scoop..."
Write-Host "###########################"

$tools = @(
    "mise",
    "curl",
    "fzf",
    "neovim",
    "pwsh",
    "starship",
    "winmerge",
    "aws",
    "aws-sam-cli",
    "lefthook",
    "make"
)

foreach($tool in $tools) {
    scoop install $tool
}

#######################
#
#   Install Mise
#
#######################
Write-Host "###########################"
Write-Host "5. install mise"
Write-Host "###########################"
$packages = @(
    "python@3.13",
    "terraform@1.11.4",
    "node@23.11.0",
    "rust@latest"
)

foreach($package in $packages) {
    mise install $package
}

npm install -g pnpm