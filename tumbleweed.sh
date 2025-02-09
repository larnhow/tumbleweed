#!/bin/bash
sudo mkdir -p /mnt/gandor
sudo mkdir -p /mnt/medis

sudo mkdir -p /etc/samba/credentials



sudo chown root:root /etc/samba/credentials
sudo chmod 700 /etc/samba/credentials

echo

if grep '//nuc8.home.arpa/gandor' /etc/fstab > /dev/null
then
      echo "share gandor already in /etc/fstab"
else
  echo -n "username for share gandor: "
  read username
  echo -n Password: 
  read -s password

  echo "username=$username" | sudo tee /etc/samba/credentials/gandor >/dev/null
  echo "password=$password" | sudo tee -a /etc/samba/credentials/gandor >/dev/null
  sudo chmodx 600 /etc/samba/credentials/gandor
    echo '//nuc8.home.arpa/gandor    /mnt/gandor    cifs    defaults,noauto,nofail,credentials=/etc/samba/credentials/gandor,x-systemd.automount,x-systemd.requires=network-online.target,gid=1000,uid=1000    0    0' | sudo tee -a /etc/fstab
fi

if grep '//nuc8.home.arpa/media' /etc/fstab > /dev/null
then
  echo "share media already in /etc/fstab"
else
  echo -n "username for share media: "
  read username
  echo -n Password: 
  read -s password

  echo "username=$username" | sudo tee /etc/samba/credentials/media >/dev/null
  echo "password=$password" | sudo tee -a /etc/samba/credentials/media >/dev/null
  sudo chmod 600 /etc/samba/credentials/media
  echo '//nuc8.home.arpa/media    /mnt/media    cifs    defaults,noauto,nofail,credentials=/etc/samba/credentials/media,x-systemd.automount,x-systemd.requires=network-online.target,gid=1000,uid=1000    0    0' | sudo tee -a /etc/fstab
fi
sudo systemctl daemon-reload

sudo systemctl start mnt-gandor.automount
sudo systemctl start mnt-media.automount

sudo tee /etc/sysctl.d/\
10-network.conf << EOF > /dev/null
net.core.default_qdisc=fq
net.ipv4.tcp_congestion_control=bbr
net.core.rmem_max=7500000
net.core.wmem_max=7500000
EOF

#sudo zypper install systemd-zram-service && sudo zramswapon && sudo systemctl enable zramswap.service
sudo tee /etc/sysctl.d/\
60-zram.conf << EOF > /dev/null
vm.page-cluster = 0
vm.swappiness = 180
EOF

sudo sysctl --system

sudo zypper in power-profiles-daemon -y
sudo systemctl enable --now power-profiles-daemon.service

sudo firewall-cmd --set-default-zone home
sudo cryptsetup --allow-discards --perf-no_read_workqueue --perf-no_write_workqueue --persistent refresh cr_root
sudo zypper install -y helix git zsh fish yazi starship btop chezmoi nvtop ansible bat eza lsd git-delta dust duf broot fd ripgrep fzf jq sd cheat bottom gping procs zoxide doggo lazygit
sudo zypper install -y ghostty keepassxc thunderbird
sudo zypper in -y sane-airscan
sudo zypper install -y google-noto-sans-cjk-fonts fontawesome-fonts symbols-only-nerd-fonts fira-code-fonts mozilla-fira-fonts inter-fonts inter-variable-fonts jetbrains-mono-fonts
sudo zypper install -y keepassxc thunderbird zathura zathura-plugin-cb zathura-plugin-djvu zathura-plugin-ps libva-utils
sudo rpm --import https://brave-browser-rpm-release.s3.brave.com/brave-core.asc
sudo zypper addrepo https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo
sudo zypper install -y brave-browser
sudo zypper install -y steam gamemode lutris mangohud dxvk xpadneo
sudo flatpak install -y com.github.rafostar.Clapper com.github.rafostar.Clapper.Enhancers io.missioncenter.MissionCenter io.github.flattool.Warehouse io.github.dvlv.boxbuddyrs io.podman_desktop.PodmanDesktop com.github.marhkb.Pods com.heroicgameslauncher.hgl com.usebottles.bottles com.mikrotik.WinBox com.mattjakeman.ExtensionManager


gsettings set org.gnome.desktop.interface font-antialiasing rgba
gsettings set org.gnome.desktop.interface font-name 'Inter 11'
gsettings set org.gnome.desktop.interface monospace-font-name 'JetBrains Mono 11'
gsettings set org.gtk.gtk4.Settings.FileChooser sort-directories-first true
gsettings set org.gnome.nautilus.list-view use-tree-view true
gsettings set org.gnome.nautilus.preferences recursive-search always
gsettings set org.gnome.nautilus.preferences show-image-thumbnails always
gsettings set org.gnome.nautilus.preferences show-directory-item-counts always

