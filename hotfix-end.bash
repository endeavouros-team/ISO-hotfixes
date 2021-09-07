#!/bin/bash
#
# Hotfixes for the ISOs that can be used after releaseing the ISO.
# This file is meant for fixes that need to be done at the end of running calamares.

DIE() {
    local type="$1"
    local msg="$2"
    echo "$progname: $type: $msg"
    exit 1
}

Main() {
    local progname=$(basename "$0")
    local file=/usr/lib/endeavouros-release
    local VERSION=""

    [ -r $file ] && source $file

    case "$VERSION" in
        "2021.08.27")
            echo "$progname: adding hotfixes after ISO $VERSION."
            # Add hotfixes here.
            ;;

        "") DIE warning "sorry, ISO version not found."
            ;;

        *)  DIE info "no hotfixes for ISO version $VERSION."
            ;;
    esac
}

Main "$@"

