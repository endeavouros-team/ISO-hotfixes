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

    # Permanent fixes common to the latest stable ISO and dev ISOs after that.

    # Remove installing of nvidia-installer-dkms.
    sed -i /etc/calamares/scripts/chrooted_cleaner_script.sh \
        -e 's|_install_needed_packages nvidia-installer-dkms nvidia-inst |_install_needed_packages nvidia-inst |'

    # ISO specific fixes.

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
            # remove the installing of nvidia-installer-dkms because it no longer exists in the repo
            sed -i /etc/calamares/scripts/chrooted_cleaner_script.sh \
                -e 's|_install_needed_packages nvidia-installer-dkms|_install_needed_packages|'
            # remove picom from install list for i3
            SkipPackageInstall picom
            ;;
        2022.11.13)  # Artemis nova November rebuild
            SkipPackageInstall ipw2100-fw ipw2200-fw grub-tools          # delete removed firmware packages from install lists (ipw2100-fw and ipw2200-fw)
            # remove grub2-theme-endeavouros from pacstrap
            sed '/  - grub2-theme-endeavouros/d' -i /etc/calamares/modules/pacstrap.conf
            ;;
        2022.12.06)  # Artemis nova December rebuild
            SkipPackageInstall ipw2100-fw ipw2200-fw grub-tools           # delete removed firmware packages from install lists (ipw2100-fw and ipw2200-fw)
            # remove grub2-theme-endeavouros from pacstrap
            sed '/  - grub2-theme-endeavouros/d' -i /etc/calamares/modules/pacstrap.conf
            ;;
        2022.12.17)  # Cassini
            # Delete removed firmware packages from install lists (ipw2100-fw and ipw2200-fw).
            SkipPackageInstall ipw2100-fw ipw2200-fw
            ;;
        2023.03.06)  # Cassini nova 
            # [hardwaredetect] Do not return error if hardware detection fails
            wget -qN -P "/usr/lib/calamares/modules/hardwaredetect/" "https://raw.githubusercontent.com/endeavouros-team/calamares/01aeb60d05c864bacc926f718686c27c69b84f49/src/modules/hardwaredetect/main.py" 
            ;;
        2023.03.26)  # Cassini nova R1 
            # [hardwaredetect] Do not return error if hardware detection fails
            wget -qN -P "/usr/lib/calamares/modules/hardwaredetect/" "https://raw.githubusercontent.com/endeavouros-team/calamares/01aeb60d05c864bacc926f718686c27c69b84f49/src/modules/hardwaredetect/main.py"
            SkipPackageInstallInFile packagechooser_ce.conf xcursor-neutral
            sed -i 's/ttf-nerd-fonts-symbols-2048-em/ttf-nerd-fonts-symbols/g' /etc/calamares/modules/packagechooser_ce.conf
            ;;
        2023.05.28)  # Cassini nova R2 
            # [hardwaredetect] Do not return error if hardware detection fails
            # wget -qN -P "/usr/lib/calamares/modules/hardwaredetect/" "https://raw.githubusercontent.com/endeavouros-team/calamares/01aeb60d05c864bacc926f718686c27c69b84f49/src/modules/hardwaredetect/main.py"
            FetchFile_timestamp "/usr/lib/calamares/modules/hardwaredetect/main.py" \
                                "https://gitlab.com/endeavouros-filemirror/calamares/-/raw/01aeb60d05c864bacc926f718686c27c69b84f49/src/modules/hardwaredetect/main.py" \
                                "https://raw.githubusercontent.com/endeavouros-team/calamares/01aeb60d05c864bacc926f718686c27c69b84f49/src/modules/hardwaredetect/main.py"
            SkipPackageInstallInFile packagechooser_ce.conf xcursor-neutral
            sed -i 's/ttf-nerd-fonts-symbols-2048-em/ttf-nerd-fonts-symbols/g' /etc/calamares/modules/packagechooser_ce.conf
            # [netinstall.yaml] fix cinnamon to not get xdg-desktop-portal-gnome installed
            sed -i '/^    - x-apps.*/ a\    - xdg-desktop-portal-gtk' /etc/calamares/modules/netinstall.yaml
            # remove xfs from offered filesystems in partition module 
            # https://github.com/calamares/calamares/issues?q=xfs
            sed -i -e 's/availableFileSystemTypes:  \["ext4","btrfs","xfs"\]/availableFileSystemTypes:  ["ext4","btrfs"]/g' /etc/calamares/modules/partition.conf
            ;;
        2023.08.05)  # Cassini nova R3 
            # [hardwaredetect] Do not return error if hardware detection fails
            # wget -qN -P "/usr/lib/calamares/modules/hardwaredetect/" "https://raw.githubusercontent.com/endeavouros-team/calamares/01aeb60d05c864bacc926f718686c27c69b84f49/src/modules/hardwaredetect/main.py"
            FetchFile_timestamp "/usr/lib/calamares/modules/hardwaredetect/main.py" \
                                "https://gitlab.com/endeavouros-filemirror/calamares/-/raw/01aeb60d05c864bacc926f718686c27c69b84f49/src/modules/hardwaredetect/main.py" \
                                "https://raw.githubusercontent.com/endeavouros-team/calamares/01aeb60d05c864bacc926f718686c27c69b84f49/src/modules/hardwaredetect/main.py"
            # Community Edition fixes
            SkipPackageInstallInFile packagechooser_ce.conf xcursor-neutral
            sed -i 's/ttf-nerd-fonts-symbols-2048-em/ttf-nerd-fonts-symbols/g' /etc/calamares/modules/packagechooser_ce.conf
            # [netinstall.yaml] fix cinnamon to not get xdg-desktop-portal-gnome installed (now in the patchfile for netinstall.yaml down there)
            # sed -i '/^    - x-apps.*/ a\    - xdg-desktop-portal-gtk' /etc/calamares/modules/netinstall.yaml
            # [netinstall.yaml] fix gnome to get xdg-desktop-portal-gnome installed for dark-light mode switch to work (Gnome 45  change)
            # + fixes for KDE (package renaming upstream)
            wget -qN -P "/tmp/" "https://raw.githubusercontent.com/endeavouros-team/ISO-hotfixes/main/netinstall.yaml-cassini-R3.patch"
            patch "/etc/calamares/modules/netinstall.yaml" < "/tmp/netinstall.yaml-cassini-R3.patch"
            # remove xfs from offered filesystems in partition module
            # https://github.com/calamares/calamares/issues?q=xfs
            sed -i -e 's/availableFileSystemTypes:  \["ext4","btrfs","xfs"\]/availableFileSystemTypes:  ["ext4","btrfs"]/g' /etc/calamares/modules/partition.conf
            ;;
        2023.10.13)  # Cassini nova R3 -last weekly rebuild
            # [netinstall.yaml] fix gnome to get xdg-desktop-portal-gnome installed for dark-light mode switch to work (Gnome 45  change)
            # + fixes for KDE (package renaming upstream)
            wget -qN -P "/tmp/" "https://raw.githubusercontent.com/endeavouros-team/ISO-hotfixes/main/netinstall.yaml-cassini-R3.patch"
            patch "/etc/calamares/modules/netinstall.yaml" < "/tmp/netinstall.yaml-cassini-R3.patch"
            ;;
        2023.11.17) # Galileo 
            # 12/6/23 KDE package rename from kgamma5 to kgamma
            sed -i 's/    - kgamma5/    - kgamma/g' /etc/calamares/modules/packagechooser.conf
            ;;
        2024.01.25) # Galileo Neo
            # Plasma 6 release fixing kde packages list
            wget -qN -P "/tmp/" "https://raw.githubusercontent.com/endeavouros-team/ISO-hotfixes/main/packagechooser.conf.patch"
            patch "/etc/calamares/modules/packagechooser.conf" < "/tmp/packagechooser.conf.patch"
            ;;
        2024.04.20) # Gemini
            # Gnome nautilus-send removed from repo
            wget -qN -P "/tmp/" "https://raw.githubusercontent.com/endeavouros-team/ISO-hotfixes/main/packagechooser.conf_gemini_1.patch"
            patch "/etc/calamares/modules/packagechooser.conf" < "/tmp/packagechooser.conf_gemini_1.patch"
            ;;
        2024.06.25) # Endeavour
            # Move fstab after lukskeyfile job so crypttab is correct [settings_online.conf] [settings_offline.conf]
            wget -qN -P "/tmp/" "https://raw.githubusercontent.com/endeavouros-team/ISO-hotfixes/main/settings_online.conf.patch"
            wget -qN -P "/tmp/" "https://raw.githubusercontent.com/endeavouros-team/ISO-hotfixes/main/settings_offline.conf.patch"
            patch "/etc/calamares/settings_online.conf" < "/tmp/settings_online.conf.patch"
            patch "/etc/calamares/settings_offline.conf" < "/tmp/settings_offline.conf.patch"
            # replace bad mirror f4st.host with moson.org in /etc/calamares/scripts/update-mirrorlist
            sed -i /etc/calamares/scripts/update-mirrorlist -e s'|https://mirror.f4st.host/archlinux/$repo/os/$arch|https://mirror.moson.org/arch/$repo/os/$arch|'
            # skip xsane from /etc/calamares/modules/netinstall.yaml
            SkipPackageInstall xsane
            ;;
        *)
            HotMsg "no hotfixes for ISO version $ISO_VERSION."
            ;;
    esac
}

Galileo-rate-mirrors-workaround() {
    local remote=$(eos-github2gitlab "https://raw.githubusercontent.com/endeavouros-team/calamares/calamares/data/eos/scripts/update-mirrorlist")
    local local=/etc/calamares/scripts/update-mirrorlist
    FetchFile "$remote" "$local"
    return 0
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
FetchFile_timestamp() {
    # Try fetching $remoteurl to $localfile. If it fails, try $remoteutl_alt instead.
    local localfile="$1"
    local remoteurl="$2"        # a github file
    local remoteurl_alt="$3"    # a gitlab file

    # wget -qN --timeout=60 -O "$localfile" "$remoteurl"
    curl -R -Lfsm 60 -o"$localfile" "$remoteurl"
    case "$?" in
        0) return ;;
        *) if [ -n "$remoteurl_alt" ] ; then
               FetchFile_timestamp "$localfile" "$remoteurl_alt" ""
           else
               HotMsg "fetching '$remoteurl' failed" warning
           fi
           ;;
    esac
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

SkipPackageInstall() {               # deprecated because of SkipPackageInstallInFile()
    # remove given packages from the list of packages to be installed
    HotMsg "skip installing package(s): $*"
    local pkg
    for pkg in "$@" ; do
        sed -E -i /etc/calamares/modules/netinstall.yaml          -e "/^[ \t]+-[ \t]+$pkg$/d"
        sed -E -i /etc/calamares/modules/netinstall-ce-base.yaml  -e "/^[ \t]+-[ \t]+$pkg$/d"
    done
}

SkipPackageInstallInFile() {
    # Example calls:
    #    SkipPackageInstallInFile /etc/calamares/modules/netinstall.yaml ipw2100-fw ipw2200-fw     # file with absolute path, then package(s)
    #    SkipPackageInstallInFile                        netinstall.yaml ipw2100-fw ipw2200-fw     # file with relative path, then package(s)
    #
    #    SkipPackageInstallInFile packagechooser_ce.conf xcursor-neutral

    local file="$1"
    local -r defpath=/etc/calamares/modules
    local pkg

    shift

    # make sure file has an absolute path
    case "$file" in
        /*) ;;                        # file has absolute path
        *) file="$defpath/$file" ;;   # file has relative path, add the default path
    esac
    HotMsg "skip installing package(s) in $file: $*"

    # handle skipping given packages
    for pkg in "$@" ; do
        sed -E -i "$file" -e "/^[ \t]+-[ \t]+$pkg$/d"
    done
}

#### Execution starts here
Main "$@"

