#!/bin/bash

set -e

ROSTER="students.json"
OUTPUT_CSV="student_credentials.csv"
DEFAULT_PASSWORD="changeme"

echo "🚀 Setting up class from $ROSTER..."

# Check dependencies
if ! command -v jq &> /dev/null; then
    echo "❌ jq is required. Run initial setup first."
    exit 1
fi

# Create CSV header
echo "username,email,password,db_name,db_user,db_password" > $OUTPUT_CSV

# Loop through students
jq -c '.[]' "$ROSTER" | while read -r student; do

    email=$(echo "$student" | jq -r '."SIS Login ID"')

    # Extract username (sanitize)
    username=$(echo "$email" | cut -d'@' -f1 | tr '[:upper:]' '[:lower:]' | tr -cd 'a-z0-9')

    echo "👤 Processing $username ($email)"

    # Skip if user exists
    if id "$username" &>/dev/null; then
        echo "⚠️ User $username already exists, skipping..."
        continue
    fi

    # -------------------------------
    # 1. Create Linux user
    # -------------------------------
    sudo adduser --disabled-password --gecos "" "$username"

    # Set default password
    echo "$username:$DEFAULT_PASSWORD" | sudo chpasswd

    # Force password change on first login
    sudo chage -d 0 "$username"

    # -------------------------------
    # 2. Setup public_html
    # -------------------------------
    sudo mkdir -p /home/"$username"/public_html

    # Copy template
    sudo cp -r /etc/skel/public_html/* /home/"$username"/public_html/ 2>/dev/null || true

    # Set ownership + permissions
    sudo chown -R "$username":"$username" /home/"$username"

    sudo chmod 711 /home/"$username"
    sudo chmod 755 /home/"$username"/public_html

    # -------------------------------
    # 3. Create MySQL DB + user
    # -------------------------------
    db_name="${username}_db"
    db_user="$username"
    db_password=$(openssl rand -base64 12)

    sudo mysql <<EOF
CREATE DATABASE ${db_name};
CREATE USER '${db_user}'@'localhost' IDENTIFIED BY '${db_password}';
GRANT ALL PRIVILEGES ON ${db_name}.* TO '${db_user}'@'localhost';
FLUSH PRIVILEGES;
EOF

    # Save DB info to user's home
    sudo tee /home/"$username"/db_info.txt > /dev/null <<EOF
DB_NAME=${db_name}
DB_USER=${db_user}
DB_PASS=${db_password}
DB_HOST=localhost
EOF

    sudo chown "$username":"$username" /home/"$username"/db_info.txt
    sudo chmod 600 /home/"$username"/db_info.txt

    # -------------------------------
    # 4. Add to CSV
    # -------------------------------
    echo "$username,$email,$DEFAULT_PASSWORD,$db_name,$db_user,$db_password" >> $OUTPUT_CSV

    echo "✅ Finished $username"
    echo "-----------------------------"

done

echo ""
echo "🎉 Class setup complete!"
echo "📄 Credentials saved to: $OUTPUT_CSV"
echo ""
echo "Students can access their sites at:"
echo "👉 http://YOUR_IP/~username"
echo ""