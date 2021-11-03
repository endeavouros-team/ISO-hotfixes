#!/bin/bash
#
# Hotfixes for the ISOs that can be used after releasing the ISO.
# This file is meant for fixes that need to be done at the end of running calamares.

MSG() {
    local type="$1"
    local msg="$2"
    echo "==> $progname: $type: $msg"
}

Main() {
    local progname=$(basename "$0")
    source /usr/share/endeavouros/scripts/eos-script-lib-yad || return 1
    local file=/usr/lib/endeavouros-release
    local VERSION=""

    [ -r $file ] && source $file

    case "$VERSION" in
        2021.08.27)
            MSG info "hotfixes after ISO $VERSION."
            # Add hotfixes here.
            ;;
        2021.10.31 | 2021.11.*)
            case "$(eos_GetDeOrWm)" in
                SWAY)
                    if ! pacman -Q ly >&/dev/null ; then
                        MSG info "sway: installing ly"
                        pacman -Syu --needed --noconfirm ly
                    fi
                    MSG info "sway: enabling ly service"
                    systemctl --force enable ly
                    ;;
            esac
            ;;

        "") MSG warning "sorry, ISO version not found."
            ;;

        *)
            MSG info "no hotfixes found for ISO version $VERSION."
            ;;
    esac
}

Main "$@"

