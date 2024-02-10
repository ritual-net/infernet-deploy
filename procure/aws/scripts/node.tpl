#! /bin/bash

# Install docker
cd ~/
sudo apt update
sudo apt-get update
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
sudo apt install -y docker-ce awscli

# Create a shell script for subsequent boots
cat << 'EOF' > $HOME/run_on_reboot.sh
#!/bin/bash

# Extract deployment files
DIR=~/deploy
mkdir -p "$DIR" && cd "$DIR"
aws ssm get-parameter --name "deploy-tar-${cluster-name}" --with-decryption --query "Parameter.Value" --output text --region "${region}" | base64 --decode > deploy.tar.gz
tar -xzvf deploy.tar.gz && rm deploy.tar.gz

# Config file
aws ssm get-parameter --name "${config-name}" --with-decryption --query "Parameter.Value" --output text --region "${region}" | base64 --decode > config.json
chmod 600 config.json

# Run docker compose
sudo docker compose up -d
EOF

# Add the script to cron to run at reboot
chmod +x $HOME/run_on_reboot.sh
(crontab -l 2>/dev/null; echo "@reboot $HOME/run_on_reboot.sh") | crontab -

# Execute script for initial setup
$HOME/run_on_reboot.sh
