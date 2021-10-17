#!/bin/bash
#
# Hotfixes for the ISOs that can be used after releasing the ISO.
# This file is meant for fixes that need to be done before starting calamares.

MSG() {
    local type="$1"
    local msg="$2"
    echo "==> $progname: $type: $msg"
}

Main() {
    local progname=$(basename "$0")
    local file=/usr/lib/endeavouros-release
    local VERSION=""

    [ -r $file ] && source $file

    case "$VERSION" in
        "2021.08.27")
            MSG info "hotfixes after ISO $VERSION."
            # Add hotfixes here.
            ;;

        "") MSG warning "sorry, ISO version not found."
            ;;

        *)  MSG info "no hotfixes found for ISO version $VERSION."
            ;;
    esac
}

Main "$@"

