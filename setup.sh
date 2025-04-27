#!/usr/bin/env bash
# kali-setup.sh — Automate post-install configuration on Kali Linux
# Run as root: chmod +x kali-setup.sh && sudo ./kali-setup.sh

set -euo pipefail

LOG="/var/log/kali-setup.log"
exec > >(tee -a "$LOG") 2>&1

echo "[$(date +'%F %T')] Starting Kali post-install setup..."

# 1. Update the System 
echo
echo "=== 1. Updating System ==="
cp /etc/apt/sources.list /etc/apt/sources.list.backup
echo "deb http://http.kali.org/kali kali-rolling main non-free contrib" | sudo tee /etc/apt/sources.list
apt-get update -y
apt install ufw openvpn gdebi wireshark tlp git gdb -y

wget -O ~/.gdbinit-gef.py -q https://gef.blah.cat/py
echo source ~/.gdbinit-gef.py >> ~/.gdbinit

apt-get full-upgrade -y
apt-get dist-upgrade -y
apt-get autoremove -y
apt-get autoclean -y

wget -O ~/.gdbinit-gef.py -q https://gef.blah.cat/py
echo source ~/.gdbinit-gef.py >> ~/.gdbinit

ufw enable

# 2. Configure SSH (if needed) 
echo
echo "=== 2. Configuring SSH ==="
SSHD_CONF="/etc/ssh/sshd_config"
sed -i 's/^#\?Port .*/Port 2222/'         "$SSHD_CONF"
sed -i 's/^#\?ListenAddress .*/ListenAddress 0.0.0.0/' "$SSHD_CONF"
sed -i 's/^#\?MaxAuthTries .*/MaxAuthTries 3/'       "$SSHD_CONF"
sed -i 's/^#\?MaxSessions .*/MaxSessions 7/'        "$SSHD_CONF"
sed -i 's/^#\?PasswordAuthentication .*/PasswordAuthentication yes/' "$SSHD_CONF"
sed -i 's/^#\?PermitRootLogin .*/PermitRootLogin yes/'             "$SSHD_CONF"
systemctl enable ssh
systemctl restart ssh

# 3. Set Up Bash and Zsh Aliases 
echo
echo "=== 3. Setting Up Aliases ==="
ALIASES=(
    "alias updateall='apt-get update && apt-get upgrade -y && apt-get autoremove -y && apt-get autoclean'"
    "alias findmyip='curl ipecho.net/plain; echo'"
)
for rc in /root/.bashrc /root/.zshrc /home/kali/.bashrc /home/kali/.zshrc; do
    for a in "${ALIASES[@]}"; do
        grep -qxF "$a" "$rc" || echo "$a" >> "$rc"
    done
done

# 4. Install Kali Metapackages 
echo
echo "=== 4. Installing Metapackage (default tools) ==="
apt-get update -y
apt-get full-upgrade -y
apt-get install -y kali-linux-default



# 6. Install Useful Terminal Tools 
echo
echo "=== 6. Installing Terminal Tools ==="
apt-get install -y guake terminator bmon bpytop
# Définir Terminator comme exécutable par défaut
gsettings set org.gnome.desktop.default-applications.terminal exec 'terminator'
# Préciser l’argument pour lancer une commande (–x ou -x selon la version)
gsettings set org.gnome.desktop.default-applications.terminal exec-arg '-x'

# 7. Set Up Tor for Anonymous Browsing 
echo
echo "=== 10. Installing Tor ==="
apt-get install -y tor torbrowser-launcher


# 8. Setting up update cronjob
mkdir /usr/share/scripts
mv update_system.py /usr/share/scripts/update_system.py 
touch /var/log/update_kali.log
chown root:root /var/log/update_kali.log
chmod 600 /var/log/update_kali.log

CRON_ENTRY="0 2 * * 0 /usr/bin/env python3 /usr/share/scripts/update_system.py"
(crontab -l && echo "0 2 * * 0 /usr/bin/env python3 /usr/share/scripts/update_system.py") | crontab -


echo
echo "[$(date +'%F %T')] Kali post-install setup complete!"
