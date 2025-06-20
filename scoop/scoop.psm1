$current=$PSScriptRoot

. "$current/bundle.ps1"
. "$current/export.ps1"
. "$current/install.ps1"

Export-ModuleMember -Function `
    Bundle,
    Export,
    Install