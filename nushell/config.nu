# config.nu
#
# Installed by:
# version = "0.107.0"
#
# This file is used to override default Nushell settings, define
# (or import) custom commands, or run any other startup tasks.
# See https://www.nushell.sh/book/configuration.html
#
# Nushell sets "sensible defaults" for most configuration settings, 
# so your `config.nu` only needs to override these defaults if desired.
#
# You can open this file in your default editor using:
#     config nu
#
# You can also pretty-print and page through the documentation for configuration
# options using:
#     config nu --doc | nu-highlight | less -R

$env.config.show_banner = false
$env.config.edit_mode = "vi"
$env.config.buffer_editor = "helix"

alias hx = helix

def pkgs [] {
    sudo pacman -Qqe | lines
    | where {|p| $p not-in (open ~/.config/excluded_pkgs.txt | lines) }
}
def pending-pkgs [] { pkgs
    | where {|p| $p not-in (open ~/.config/approved_pkgs.txt | lines) }
}
def approve-pkgs [] { pending-pkgs | save -a approved_pkgs.txt }
def missing-pkgs [] {
    open ~/.config/approved_pkgs.txt | lines
    | where {|p| $p not-in (pkgs) }
}
def install-missing [] {
    missing-pkgs
    | each {|p| sudo pacman -S --needed $p | ignore }
}
def install-missing-paru [] {
    missing-pkgs | each {|p| paru -S $p }
}

# starship
mkdir ($nu.data-dir | path join "vendor/autoload")
starship init nu
    | save -f ($nu.data-dir | path join "vendor/autoload/starship.nu")

# fnm
$env.PATH = ($env.PATH
    | split row (char esep)
    | prepend $"($env.FNM_MULTISHELL_PATH)/bin"
)

source ~/.zoxide.nu
