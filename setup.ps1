#######################
#
#   setup 
#
#######################
Remove-Module scoop -Force -ErrorAction SilentlyContinue

$current=$PSScriptRoot
Import-Module "$current/scoop" -Prefix scoop

# construct directories

# setup scoop
scoopSetup

# git repository install

scoopBundle

# scoop bundle install

# link starship config

# link mise config

# link pwsh profile

# winget install

# setup background image





Write-Host "###########################"
Write-Host "1. setup "
Write-Host "###########################"

$userprofile = $env:USERPROFILE

$directories = @(
    "$userprofile\environments",
    "$userprofile\environments\github",
    "$userprofile\environments\github\work",
    "$userprofile\environments\github\rsi\external",
    "$userprofile\environments\github\rsi\internal",
    "$userprofile\environments\gitlab\external"
    "$userprofile\environments\gitlab\internal"
)