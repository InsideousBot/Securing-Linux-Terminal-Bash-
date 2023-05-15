#!/bin/bash

# Check if the script is running as root
if [ "$EUID" -ne 0 ]
  then echo "Please run as root."
  exit
fi

# Update package lists and upgrade installed packages
echo "Updating packages..."
apt update && apt upgrade -y

# Install security tools
echo "Installing security tools..."
apt install -y ufw fail2ban rkhunter

# Enable and configure the Uncomplicated Firewall
echo "Configuring the Uncomplicated Firewall..."
ufw default deny incoming
ufw default allow outgoing
ufw allow ssh
ufw allow http
ufw allow https
ufw enable

# Configure Fail2Ban
echo "Configuring Fail2Ban..."
systemctl enable fail2ban
systemctl start fail2ban

cat > /etc/fail2ban/jail.local <<- EOM
[sshd]
enabled = true
banaction = ufw
maxretry = 5
bantime = 86400
findtime = 3600
EOM

systemctl restart fail2ban

# Run Rootkit Hunter
echo "Running Rootkit Hunter..."
rkhunter --update
rkhunter --propupd
rkhunter -c --enable all --disable none

echo "Basic security measures applied. Further steps may be required for complete system security."
