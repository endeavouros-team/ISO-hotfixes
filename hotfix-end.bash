#!/bin/bash
#
# Hotfixes for the ISOs that can be used after releasing the ISO.
# This file is meant for fixes that need to be done at the end of running calamares.

Main() {
    local progname="$(basename "$0")"
    source /usr/share/endeavouros/scripts/eos-script-lib-yad || return 1
    local ISO_VERSION="$(IsoVersion)"
    local DE="$(eos_GetDeOrWm)"

    # Add hotfixes below:
    # - For ISO version specific hotfixes: use the $ISO_VERSION variable.
    # - For DE/WM specific hotfixes: use the $DE variable (all upper case letters).
    # - Make sure execution does NOT stop (e.g. to ask a password) nor EXIT!

    case "$ISO_VERSION" in
        2021.11.30 | 2021.12.*)  # for "Atlantis" and "Atlantis neo"
            HotMsg "hotfixes after ISO $ISO_VERSION."
            Hotfix_sway_ly
            ;;
        "")
            HotMsg "ISO version not found." warning
            ;;
        *)
            HotMsg "no hotfixes for ISO version $ISO_VERSION."
            ;;
    esac
}

Hotfix_sway_ly() {
    case "$DE" in
        SWAY)
            if ! pacman -Q ly >& /dev/null ; then
                HotMsg "sway: installing ly"
                pacman -Syu --needed --noconfirm ly ttf-nerd-fonts-symbols
            fi
            HotMsg "sway: enabling ly service"
            systemctl --force enable ly
            ;;
    esac
}

#### Common services:

HotMsg() {
    local msg="$1"
    local type="$2"
    [ -n "$type" ] || type=info
    echo "==> $progname: $type: $msg"
}

IsoVersion() {
    local VERSION=""
    local file=/usr/lib/endeavouros-release
    LANG=C source $file || return
    echo "$VERSION"
}

IsPackageVersion() {
    local pkgname="$1"
    local version="$2"
    [ "$(pacman -Q $pkgname | awk '{print $2}')" = "$version" ] && return 0 || return 1
}

FetchFile() {
    local remote="$1"
    local local="$2"
    curl --fail -Lsm 60 -o "$local" "$remote" || HotMsg "fetching new '$local' failed" warning
}

#### Execution starts here
Main "$@"

