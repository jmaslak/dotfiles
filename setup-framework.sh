#!/bin/bash

#
# Copyright (C) 2023 Joelle Maslak
# All Rights Reserved - See License
#

doit() {
    # sudo dpkg -i $(ls src/framework-tweaks/framework-tweaks*.deb | tail -1)
    sudo apt update && \
        sudo apt upgrade -y && \
        sudo snap refresh && \
        sudo apt-get install linux-oem-22.04c -y && \
        echo "options snd-hda-intel model=dell-headset-multi" | \
        sudo tee -a /etc/modprobe.d/alsa-base.conf && \
        gsettings set org.gnome.mutter experimental-features "['scale-monitor-framebuffer']" && \
        sudo sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT.*/GRUB_CMDLINE_LINUX_DEFAULT="quiet splash module_blacklist=hid_sensor_hub nvme.noacpi=1"/g' /etc/default/grub && \
        sudo update-grub && \
        echo "[connection]" | sudo tee /etc/NetworkManager/conf.d/default-wifi-powersave-on.conf && \
        echo "wifi.powersave = 2" | sudo tee -a /etc/NetworkManager/conf.d/default-wifi-powersave-on.conf

    echo "You'll want to reboot to get your brightness buttons working!"
}

doit "$@"


