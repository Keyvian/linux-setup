apt update
apt-get full-upgrade -y
apt dist-upgrade -y
apt autoremove -y
apt autoclean -y

kdir /usr/share/scripts
mv update_system.py /usr/share/script/update_system.py 

(crontab -l && echo "0 2 * * 0 /usr/bin/python3 /usr/share/script/update_system.py") | crontab -
