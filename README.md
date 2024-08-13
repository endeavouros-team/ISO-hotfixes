# ISO-hotfixes

[![Maintenance](https://img.shields.io/maintenance/yes/2024.svg)]()

Descriptions of the hotfixes after ISO releases.

Details: see files [hotfix-start.bash](hotfix-start.bash) and [hotfix-end.bash](hotfix-end.bash).

Hotfix date | Affected ISO | Hotfix file | Description
:--- | :--- | :--- | :---
2024.08.12| EndeavourOS_Endeavour-2024.06.25.iso| hotfix-start.bash | [hotfix-start.bash] replace bad mirror f4st.host with moson.org in /etc/calamares/scripts/update-mirrorlist
~~2024.07.21~~| ~~EndeavourOS_Endeavour-2024.06.25.iso~~| ~~hotfix-start.bash~~ | [~~hotfix-start.bash]~~  ~~adding changed mirrorlist to livesession~~
2024.07.14 | EndeavourOS_Endeavour-2024.06.25.iso| hotfix-start.bash | Move fstab after lukskeyfile job so crypttab is correct [settings_online.conf] [settings_offline.conf]
2024.06.19 | EndeavourOS_Gemini-2024.04.20.iso | hotfix-start.bash | Gnome nautilus-send removed from repo [packagechooser.conf]
2024.03.25 | EndeavourOS_Galileo-Neo-2024.01.25.iso | hotfix-start.bash | add tracker3-miners for GNOME 46 [packagechooser.conf]
2024.03.07 | EndeavourOS_Galileo-Neo-2024.01.25.iso | hotfix-start.bash | KDE package-list update for Plasma 6 release [packagechooser.conf]
2023.12.06 | Endeavouros-Galileo-11-2023.iso | hotfix-start.bash | KDE package rename from kgamma5 to kgamma (thanks to Schmitz at telegram for reporting!)
2023.10.20 | EndeavourOS_Cassini_Nova-03-2023_R3.iso (weekly 2023.10.13) | hotfix-start.bash | adding fixes for kde package renaming for Cassini nova R3 -last weekly rebuild (2023.10.13)
2023.10.20 | EndeavourOS_Cassini_Nova-03-2023_R3.iso | hotfix-start.bash | adding fixes for kde package renaming
2023.10.19 | EndeavourOS_Cassini_Nova-03-2023_R3.iso | hotfix-start.bash | fix gnome to get xdg-desktop-portal-gnome for dark-light mode switcher (GNOME 45)
2023.08.05 | EndeavourOS_Cassini_Nova-03-2023_R3.iso | hotfix-start.bash | add R3 to get hotfixes applied too (Cassini), xfs FS removed from options on autopartitions currently (also added for R2 ISO)
2023.06.28 | EndeavourOS_Cassini_Nova-03-2023_R2.iso | hotfix-start.bash | [netinstall.yaml] fix cinnamon to not get xdg-desktop-portal-gnome installed
2023.05.28 | EndeavourOS_Cassini_Nova-03-2023_R2.iso | hotfix-start.bash | add R2 to get hotfixes applied too (Cassini)
2023.05.03 | EndeavourOS_Cassini_Nova-03-2023_R1.iso | hotfix-start.bash | replace ttf-nerd-fonts-symbols-2048-em with ttf-nerd-fonts-symbols for CE
2023.04.02 | EndeavourOS_Cassini_Nova-03-2023_R1.iso | hotfix-start.bash | Skip install of xcursor-neutral on community editions
2023.03.18<br>2023.03.29 | EndeavourOS_Cassini_Nova-03-2023.iso  EndeavourOS_Cassini_Nova-03-2023_R1.iso| hotfix-start.bash | [hardwaredetect] Do not return error if hardware detection fails
2022-Nov-12 +Dec-06| EndeavourOS_Artemis_nova_22_11.iso +22_12 | hotfix-start.bash | delete removed firmware packages from install lists (ipw2100-fw and ipw2200-fw)<br> for all online installs. <br> remove grub2-theme-endeavouros from pacstrap
2022-Sep-22 | EndeavourOS_Artemis_nova_22_9.iso | hotfix-start.bash | delete removed firmware packages from install lists (ipw2100-fw and ipw2200-fw)<br> for all online installs. <br>exchange nitrogen with feh for i3 installs. <br> remove picom from install list for i3 installs.
2022-Sep-04 | EndeavourOS_Artemis_neo_22_8.iso | hotfix-start.bash | Font package<br>`ttf-nerd-fonts-symbols`<br> changed to<br> `ttf-nerd-fonts-symbols-2048-em`<br> for community editions.


<br>
