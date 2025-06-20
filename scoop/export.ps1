function Export() {
    $current = $PSScriptRoot
    scoop export > "$current/bundle.json"
}