#!/bin/bash
#
# Hotfixes for the ISOs that can be used after releasing the ISO.
# This file is meant for fixes that need to be done before starting calamares.

Main() {
    local progname=$(basename "$0")
    source /usr/share/endeavouros/scripts/eos-script-lib-yad || return 1
    local ISO_VERSION="$(IsoVersion)"
    local DE="$(eos_GetDeOrWm)"

    # Add hotfixes below:
    # - For ISO version specific hotfixes: use the $ISO_VERSION variable.
    # - For DE/WM specific hotfixes: use the $DE variable (all upper case letter).
    # - Make sure execution does NOT stop (e.g. to ask a password) nor EXIT!

    case "$ISO_VERSION" in
        2021.11.30)  # Atlantis 2021.11.30
            HotMsg "hotfixes after ISO $ISO_VERSION"
            Atlantis_fix_update-mirrorlist
            Atlantis_fix_installer_start
            ;;
        2021.12.*)  # Atlantis neo
            Update_packages calamares_config_ce calamares_config_default
            ;;
        "")
            HotMsg "ISO version not found." warning
            ;;
        *)
            HotMsg "no hotfixes for ISO version $ISO_VERSION."
            ;;
    esac
}

Atlantis_fix_update-mirrorlist() {
    if IsPackageVersion calamares_current 3.2.47-5 ; then
        if eos-connection-checker ; then
            local remote="$(eos-github2gitlab "https://github.com/endeavouros-team/EndeavourOS-calamares/raw/main/calamares/scripts/update-mirrorlist")"
            local local="/etc/calamares/scripts/update-mirrorlist"
            FetchFile "$remote" "$local"
        else
            HotMsg "$FUNCNAME: no internet connection!" warning
        fi
    fi
    return 0
}
Atlantis_fix_installer_start() {
    local file=/usr/bin/eos-install-mode-run-calamares
    if [ -n "$(grep "workdir 2>/dev/null" $file)" ] ; then
        sudo sed \
             -i $file \
             -e 's|workdir 2>/dev/null|workdir >/dev/null|' \
             -e 's|popd 2>/dev/null|popd >/dev/null|'

        local icon==/usr/share/endeavouros/EndeavourOS-icon.png
        local txt=""
        txt+="Currently the <b>Atlantis</b> release requires clicking the install button a second time\n"
        txt+="in order to actually start the install process.\n\n"
        txt+="Users are advised to download the <b>Atlantis neo</b> release\n"
        txt+="where this issue is already fixed.\n\n"
        txt+="Sorry for the inconvenience.\n"
        eos_yad --form --image=dialog-information --button=yad-quit --title="Hotfix information" --text="$txt"
    fi
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
    local localtmp=$(mktemp)
    if curl --fail -Lsm 60 -o "$localtmp" "$remote" ; then
        sudo cp $localtmp "$local"
    else
        HotMsg "fetching new '$local' failed" warning
    fi
    rm $localtmp
}

Update_packages() {  # parameters: package names
    local pkg pkgs=()
    for pkg in "$@" ; do
        if pacman -Q $pkg  >& /dev/null ; then
            pkgs+=("$pkg")
        fi
    done
    if [ -n "$pkgs" ] ; then
        HotMsg "$DE: updating ${pkgs[*]}"
        pacman -Sy --noconfirm "${pkgs[@]}"
    fi
}

#### Execution starts here
Main "$@"

