#!/bin/bash

# Check if Script is Run as Root
if [[ $EUID -ne 0 ]]; then
  echo "You must be a root user to run this script, please run ./install.sh" 2>&1
  exit 1
fi

username=$(id -u -n 1000)
builddir=$(pwd)

# Update packages list and update system
apt update
apt upgrade -y

# Install nala
apt install nala -y

# Installing dependencies
nala install -y curl gcc perl neofetch wget

# Install KDE Desktop Environment
nala install kde-plasma-desktop -y
# nala install kde-standard -y

# Installing fonts
cd "$builddir" || exit
nala install fonts-font-awesome -y
# wget https://github.com/ryanoasis/nerd-fonts/releases/download/v2.3.3/FiraCode.zip
# unzip FiraCode.zip -d "/home/$username/.fonts"
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v2.3.3/CascadiaCode.zip
unzip CascadiaCode.zip -d "/home/$username/.fonts"
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v2.3.3/Meslo.zip
unzip Meslo.zip -d "/home/$username/.fonts"
# wget https://use.fontawesome.com/releases/v5.15.4/fontawesome-free-5.15.4-desktop.zip
# unzip fontawesome-free-5.15.4-desktop.zip
# cp fontawesome-free-5.15.4-desktop/otfs/*.otf "/home/$username/.fonts/"
wget https://use.fontawesome.com/releases/v6.3.0/fontawesome-free-6.3.0-desktop.zip
unzip fontawesome-free-6.3.0-desktop.zip
cp fontawesome-free-6.3.0-desktop/otfs/*.otf "/home/$username/.fonts/"
chown "$username:$username" "/home/$username/.fonts/*"

# Reloading Font
fc-cache -vf
# Removing zip Files
rm -rf ./fontawesome-free-6.3.0-desktop* ./CascadiaCode.zip ./Meslo.zip

# Removing snap
systemctl disable snapd.service
systemctl disable snapd.socket
systemctl disable snapd.seeded.service
snaps=$(snap list | awk 'NR>1{print $1}' | tr " " "\n" | sort -u | tr "\n" " ")
for snap in "${snaps[@]}"; do
  snap remove $snap
done
nala autoremove --purge snapd -y
rm -rf /var/cache/snapd/
apt-mark hold snapd

# Installing flatpak
nala install flatpak -y
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Installing other utilities (in case kde-plasma-desktop is installed)
flatpak install -y --noninteractive org.kde.kalk

# Install Google Chrome
nala install -y fonts-liberation libu2f-udev
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
dpkg -i google-chrome-stable_current_amd64.deb
rm -f google-chrome-stable_current_amd64.deb

# Install Visual Studio Code
nala install gpg -y
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
rm -f packages.microsoft.gpg
nala install apt-transport-https -y
nala update
nala install code -y

# Enable graphical login and change target from CLI to GUI
systemctl enable sddm
systemctl set-default graphical.target

# Cleaning up KDE
nala remove -y byobu tilix

# Set bash to use nala instead of apt
bash scripts/usenala.sh
