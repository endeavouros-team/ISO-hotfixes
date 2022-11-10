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

    if [ -z "$ISO_VERSION" ] ; then
        HotMsg "ISO version not found!" warning
        return
    fi

    HotMsg "hotfixes after ISO $ISO_VERSION"

    case "$ISO_VERSION" in
        2021.11.30)  # Atlantis 2021.11.30
            Atlantis_fix_update-mirrorlist
            Atlantis_fix_installer_start
            ;;
        2021.12.*)  # Atlantis neo
            Atlantis_neo_fix
            # Update_packages calamares_config_ce calamares_config_default
            ;;
        2022.03.30)
            SkipPackageInstall pcurses            # remove pcurses
            ;;
        2022.04.08)  # Apollo
            HotMsg "remove the uninstalling of qt6-base (in offline install) because eos-quickstart needs it"
            sed -i /etc/calamares/scripts/chrooted_cleaner_script.sh \
                -e 's|\(qt6-base\)|# \1|' \
                -e 's|^rm -R /etc/calamares /opt/extra-drivers|rm -rf /etc/calamares /opt/extra-drivers|'
            if eos-connection-checker ; then
                HotMsg "fix a keyring issue by installing latest archlinux-keyring before pacstrap"
                sed -i /etc/calamares/modules/shellprocess_initialize_pacman.conf \
                    -e '/^script:$/a \ - command: "pacman -Sy --needed --noconfirm archlinux-keyring"\n   timeout: 1200'
            fi
            SkipPackageInstall pipewire-media-session            # package pipewire-media-session is no more available officially
            ;;
        2022.08.28)  # Artemis neo (second version with grub fix)
            # font name change for community editions
            sed -i /etc/calamares/modules/packagechooser_ce.conf -e 's|\(- ttf-nerd-fonts-symbols\)|\1-2048-em|'
            ;;
        2022.09.10)  # Artemis nova
            SkipPackageInstall ipw2100-fw ipw2200-fw            # delete removed firmware packages from install lists (ipw2100-fw and ipw2200-fw)
            # exchange nitrogen with feh for i3 installs
            sed -i 's/    - nitrogen/    - feh/g' /etc/calamares/modules/netinstall.yaml
            ;;
        2022.10.18)  # Artemis nova October rebuild
            SkipPackageInstall ipw2100-fw ipw2200-fw            # delete removed firmware packages from install lists (ipw2100-fw and ipw2200-fw)
            ;;
        *)
            HotMsg "no hotfixes for ISO version $ISO_VERSION."
            ;;
    esac
}

Atlantis_neo_fix() {
    if ! eos-connection-checker ; then
        HotMsg "$FUNCNAME: no internet connection!" warning
        return   # fail
    fi

    # Swap lines of /etc/calamares/settings_community.conf:
    #   - contextualprocess
    #   - packages@online

    local file=/etc/calamares/settings_community.conf
    local file2=$file.tmp123
    mv $file $file2
    grep -Pv 'contextualprocess|packages@online' $file2 | sed '/user_pkglist/i \  - packages@online\n  - contextualprocess' > $file
    rm -f $file2

    # fix pcurses
    sed -i /etc/calamares/modules/netinstall.yaml                  -e '/pcurses$/d'
    sed -i /etc/calamares/modules/netinstall-ce-base.yaml          -e '/pcurses$/d'

    # Fix netinstall*.yaml for community editions by removing the https URLs
    sed -i /etc/calamares/modules/netinstall.conf                  -e '/gitlab/d'
    sed -i /etc/calamares/modules/netinstall_community-base.conf   -e '/gitlab/d'

    # fix missing icons in Xfce panel and i3
    sed -i /etc/calamares/modules/netinstall.yaml   -e 's|^\(     [ ]*\)- arc-x-icons-theme$|\1- eos-qogir-icons|'
    sed -i /etc/calamares/modules/netinstall.yaml   -e '337s|arc-x-icons-theme|eos-qogir-icons|'
}

Atlantis_fix_update-mirrorlist() {
    if [ "$(PackageVersion calamares_current)" = "3.2.47-5" ] ; then
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

PackageVersion() {
    local pkgname="$1"
    pacman -Q "$pkgname" | awk '{print $2}'
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

SkipPackageInstall() {
    # remove given packages from the list of packages to be installed
    HotMsg "skip installing package(s): $*"
    local pkg
    for pkg in "$@" ; do
        sed -E -i /etc/calamares/modules/netinstall.yaml          -e "/^[ \t]+-[ \t]+$pkg$/d"
        sed -E -i /etc/calamares/modules/netinstall-ce-base.yaml  -e "/^[ \t]+-[ \t]+$pkg$/d"
    done
}

#### Execution starts here
Main "$@"

