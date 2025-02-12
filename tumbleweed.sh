#!/bin/bash

PREFIX="/mnt"
SERVER="nuc8.home.arpa"

function add_share() {
  SERVER=$1
  SHARE=$2
  PREFIX=$3
  CREDENTIALS_DIR="/etc/samba/credentials"
  sudo mkdir -p $PREFIX/$SHARE
  sudo mkdir -p $CREDENTIALS_DIR
  sudo chown root:root $CREDENTIALS_DIR
  sudo chmod 700 $CREDENTIALS_DIR
    
  if grep "//$SERVER/$SHARE" /etc/fstab > /dev/null
  then
    echo "share $SHARE already in /etc/fstab"
  else
    echo -n "username for share $SHARE: "
    read username
    echo -n Password: 
    read -s password

    echo "username=$username" | sudo tee $CREDENTIALS_DIR/$SHARE >/dev/null
    echo "password=$password" | sudo tee -a $CREDENTIALS_DIR/$SHARE >/dev/null
    sudo chmod 600 $CREDENTIALS_DIR/$SHARE
    echo "//$SERVER/$SHARE    $PREFIX/$SHARE    cifs    defaults,noauto,nofail,credentials=$CREDENTIALS_DIR/$SHARE,x-systemd.automount,x-systemd.requires=network-online.target,gid=1000,uid=1000    0    0" | sudo tee -a /etc/fstab
  fi
  sudo systemctl daemon-reload
  sudo systemctl start mnt-$SHARE.automount

}

add_share $SERVER gandor $PREFIX
add_share $SERVER media $PREFIX

sudo tee /etc/sysctl.d/\
10-network.conf << EOF > /dev/null
net.core.default_qdisc=fq
net.ipv4.tcp_congestion_control=bbr
net.core.rmem_max=7500000
net.core.wmem_max=7500000
EOF

sudo zypper install systemd-zram-service 
sudo zramswapon || true # hack to continue if already enabled
sudo systemctl enable zramswap.service

sudo tee /etc/sysctl.d/\
60-zram.conf << EOF > /dev/null
vm.page-cluster = 0
vm.swappiness = 180
EOF

sudo sysctl --system

# https://www.reddit.com/r/openSUSE/comments/1gnkpzq/minimal_tumbleweed_i_dont_like_patterns_so_i_dont/
# sudo zypper install -y gnome-session-wayland gnome-console xdg-user-dirs-gtk pipewire-pulseaudio gnome-keyring desktop-file-utils gnome-backgrounds wallpaper-branding-openSUSE distribution-logos-openSUSE-icons flatpak podman distrobox


sudo zypper install -y power-profiles-daemon
sudo systemctl enable --now power-profiles-daemon.service

sudo firewall-cmd --set-default-zone home
sudo cryptsetup --allow-discards --perf-no_read_workqueue --perf-no_write_workqueue --persistent refresh cr_root
sudo zypper install -y helix git zsh fish yazi starship btop chezmoi nvtop ansible bat eza lsd git-delta dust duf broot fd ripgrep fzf jq sd cheat bottom gping procs zoxide doggo lazygit
sudo zypper install -y ghostty keepassxc thunderbird zathura zathura-plugin-cb zathura-plugin-djvu zathura-plugin-ps libva-utils sane-airscan
sudo zypper install -y google-noto-sans-cjk-fonts fontawesome-fonts symbols-only-nerd-fonts fira-code-fonts mozilla-fira-fonts inter-fonts inter-variable-fonts jetbrains-mono-fonts

sudo rpm --import https://brave-browser-rpm-release.s3.brave.com/brave-core.asc
sudo zypper addrepo https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo
sudo zypper install -y brave-browser

sudo zypper install com.valvesoftware.Steam gamemode mangohud dxvk xpadneo-kmp-default

sudo flatpak install -y com.github.rafostar.Clapper com.github.rafostar.Clapper.Enhancers io.missioncenter.MissionCenter io.github.flattool.Warehouse io.github.dvlv.boxbuddyrs io.podman_desktop.PodmanDesktop com.github.marhkb.Pods com.heroicgameslauncher.hgl com.usebottles.bottles com.mikrotik.WinBox com.mattjakeman.ExtensionManager


gsettings set org.gnome.desktop.interface font-antialiasing rgba
gsettings set org.gnome.desktop.interface font-name 'Inter 11'
gsettings set org.gnome.desktop.interface monospace-font-name 'JetBrains Mono 11'
gsettings set org.gtk.gtk4.Settings.FileChooser sort-directories-first true
gsettings set org.gnome.nautilus.list-view use-tree-view true
gsettings set org.gnome.nautilus.preferences recursive-search always
gsettings set org.gnome.nautilus.preferences show-image-thumbnails always
gsettings set org.gnome.nautilus.preferences show-directory-item-counts always

