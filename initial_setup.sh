#!/bin/bash

set -e

echo "🚀 Starting initial server setup..."

# -------------------------------
# 1. Update system
# -------------------------------
sudo apt update && sudo apt upgrade -y

# -------------------------------
# 2. Install core packages
# -------------------------------
echo "📦 Installing Apache, PHP, MySQL, and utilities..."

sudo apt install -y \
    apache2 \
    mysql-server \
    php \
    libapache2-mod-php \
    php-mysql \
    jq \
    unzip \
    curl

# -------------------------------
# 3. Enable Apache modules
# -------------------------------
echo "🔧 Enabling Apache modules..."

sudo a2enmod userdir
sudo a2enmod rewrite

# -------------------------------
# 4. Configure UserDir (~username)
# -------------------------------
echo "🌐 Configuring Apache UserDir..."

USERDIR_CONF="/etc/apache2/mods-enabled/userdir.conf"

sudo tee $USERDIR_CONF > /dev/null <<EOF
<IfModule mod_userdir.c>
    UserDir public_html
    UserDir disabled root

    <Directory /home/*/public_html>
        AllowOverride All
        Options Indexes FollowSymLinks
        Require all granted
    </Directory>
</IfModule>
EOF

# -------------------------------
# 5. Adjust Apache main config (ensure access)
# -------------------------------
echo "🔐 Ensuring Apache can access home directories..."

APACHE_CONF="/etc/apache2/apache2.conf"

if ! grep -q "/home/*/public_html" $APACHE_CONF; then
    sudo tee -a $APACHE_CONF > /dev/null <<EOF

<Directory /home/*/public_html>
    AllowOverride All
    Options Indexes FollowSymLinks
    Require all granted
</Directory>
EOF
fi

# -------------------------------
# 6. Secure PHP for classroom use and enable PHP for user directories
# -------------------------------
echo "🛡️ Configuring PHP for classroom use..."

# Detect loaded php.ini
PHP_INI=$(php -i | grep "Loaded Configuration File" | awk '{print $5}')

# Basic security / classroom settings
sudo sed -i "s/^display_errors = .*/display_errors = On/" "$PHP_INI"
sudo sed -i "s/^max_execution_time = .*/max_execution_time = 5/" "$PHP_INI"
sudo sed -i "s/^memory_limit = .*/memory_limit = 64M/" "$PHP_INI"
sudo sed -i "s/^disable_functions =.*/disable_functions = exec,passthru,shell_exec,system,proc_open,popen/" "$PHP_INI"

# -------------------------------
# Enable PHP in user directories (mod_userdir)
# -------------------------------
# Detect PHP module version for Apache
PHP_VER=$(php -r 'echo PHP_MAJOR_VERSION.".".PHP_MINOR_VERSION;')

# Comment out "php_admin_flag engine Off" in mod_userdir PHP config
PHP_MOD_CONF="/etc/apache2/mods-enabled/php${PHP_VER}.conf"
if [ -f "$PHP_MOD_CONF" ]; then
    sudo sed -i 's/^\s*php_admin_flag engine Off/#php_admin_flag engine Off/' "$PHP_MOD_CONF"
    echo "✅ Enabled PHP execution in ~/public_html for all users"
fi

# -------------------------------
# 7. Restart Apache
# -------------------------------
echo "🔄 Restarting Apache..."

sudo systemctl restart apache2
sudo systemctl enable apache2

# -------------------------------
# 8. Setup MySQL (basic)
# -------------------------------
echo "🗄️ Configuring MySQL..."

sudo systemctl enable mysql
sudo systemctl start mysql

# Secure root account (no password, unix_socket auth)
sudo mysql <<EOF
DELETE FROM mysql.user WHERE User='';
DROP DATABASE IF EXISTS test;
FLUSH PRIVILEGES;
EOF

# -------------------------------
# 9. Firewall (optional but recommended)
# -------------------------------
echo "🔥 Configuring firewall..."

sudo apt install -y ufw

sudo ufw allow OpenSSH
sudo ufw allow 'Apache Full'

sudo ufw --force enable

# -------------------------------
# 10. Create /etc/skel/public_html template
# -------------------------------
echo "📁 Creating default student template..."

sudo mkdir -p /etc/skel/public_html

sudo tee /etc/skel/public_html/index.html > /dev/null <<EOF
<!DOCTYPE html>
<html>
<head>
    <title>Welcome</title>
</head>
<body>
    <h1>Your site is working</h1>
    <p>Edit this file in public_html</p>
</body>
</html>
EOF

sudo chmod 755 /etc/skel/public_html

# -------------------------------
# 11. Ensure SSH allows password login
# -------------------------------
echo "🔑 Configuring SSH to allow password authentication..."

# Main config
sudo sed -i "s/^#PasswordAuthentication.*/PasswordAuthentication yes/" /etc/ssh/sshd_config
sudo sed -i "s/^PasswordAuthentication.*/PasswordAuthentication yes/" /etc/ssh/sshd_config
sudo sed -i "s/^#ChallengeResponseAuthentication.*/ChallengeResponseAuthentication yes/" /etc/ssh/sshd_config
sudo sed -i "s/^ChallengeResponseAuthentication.*/ChallengeResponseAuthentication yes/" /etc/ssh/sshd_config
sudo sed -i "s/^#UsePAM.*/UsePAM yes/" /etc/ssh/sshd_config
sudo sed -i "s/^UsePAM.*/UsePAM yes/" /etc/ssh/sshd_config

# Disable cloud-init overrides
if [ -d /etc/ssh/sshd_config.d ]; then
    for f in /etc/ssh/sshd_config.d/*.conf; do
        echo "📄 Renaming override file: $f"
        sudo mv "$f" "$f.bak"
    done
fi

# Restart SSH
sudo systemctl restart ssh
sudo systemctl enable ssh

echo "✅ SSH password login enabled"

# -------------------------------
# DONE
# -------------------------------
echo ""
echo "✅ Setup complete!"
echo ""
echo "Next steps:"
echo "1. Run your student creation script"
echo "2. Visit: http://YOUR_IP/~username"
echo ""