#! /bin/bash

# Script to setup a node in an AWS ECS cluster. Scripts on AWS only run once, so we
# need to set up a cron job to run and bring services back up on reboot. Installation
# of docker and docker-compose is also necessary, and will only only happen once at
# the time of node creation.

# Install docker
cd ~/
sudo apt update
sudo apt-get update
sudo apt-get upgrade -y
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
sudo apt install -y docker-ce awscli

# Install GPU driver if necessary
GPU="${gpu}"
if [ "$GPU" = "true" ]; then
    if ! nvidia-smi &> /dev/null
    then
        echo "nvidia-smi could not be found, installing NVIDIA drivers..."
        sudo apt-get install -y nvidia-driver-470
    else
        echo "nvidia-smi is already installed and functioning correctly."
    fi
else
    echo "GPU not enabled for this instance."
fi

# Create a shell script for subsequent boots
cat << 'EOF' > $HOME/run_on_reboot.sh
#!/bin/bash

# Extract deployment files
DIR=~/deploy
mkdir -p "$DIR" && cd "$DIR"
aws ssm get-parameter --name "deploy-tar-${node-name}" --with-decryption --query "Parameter.Value" --output text --region "${region}" | base64 --decode > deploy.tar.gz
tar -xzvf deploy.tar.gz && rm deploy.tar.gz

# Config file
aws ssm get-parameter --name "${node-name}.json" --with-decryption --query "Parameter.Value" --output text --region "${region}" | base64 --decode > config.json
chmod 600 config.json

# Run docker compose
sudo docker compose up -d
EOF

# Add the script to cron to run at reboot
chmod +x $HOME/run_on_reboot.sh
(crontab -l 2>/dev/null; echo "@reboot $HOME/run_on_reboot.sh") | crontab -

# Execute script for initial setup
$HOME/run_on_reboot.sh
