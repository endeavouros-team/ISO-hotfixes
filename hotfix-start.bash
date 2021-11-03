#!/bin/bash
#
# Hotfixes for the ISOs that can be used after releasing the ISO.
# This file is meant for fixes that need to be done before starting calamares.

HotMsg() {
    local msg="$1"
    echo "==> $progname: $msg"
}

Main() {
    local progname=$(basename "$0")
    source /usr/share/endeavouros/scripts/eos-script-lib-yad || return 1
    local file=/usr/lib/endeavouros-release
    local VERSION=""
    local DE="$(eos_GetDeOrWm)"

    [ -r $file ] && source $file

    # Add hotfixes below:
    # - For ISO version specific hotfixes: use the $VERSION variable.
    # - For DE/WM specific hotfixes: use the $DE variable (all upper case letter).
    # - Make sure execution does NOT stop (e.g. to ask a password) nor EXIT!

    case "$VERSION" in
        "")
            HotMsg "warning: ISO version not found."
            ;;
        2021.08.27)
            HotMsg "hotfixes after ISO $VERSION."
            # Add hotfixes here.
            ;;
        *)
            HotMsg "no hotfixes for ISO version $VERSION."
            ;;
    esac
}

Main "$@"

