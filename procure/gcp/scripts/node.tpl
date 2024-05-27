#! /bin/bash

# Install docker
cd ~/
sudo apt update
sudo apt-get update
sudo apt-get upgrade -y
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
sudo apt install -y docker-ce docker-compose-plugin

# Install GPU driver if necessary
GPU="${gpu}"
if [ "$GPU" = "true" ]; then
    if ! command -v nvidia-smi &> /dev/null
    then
        echo "nvidia-smi could not be found, installing NVIDIA drivers..."
        sudo /opt/deeplearning/install-driver.sh
    else
        echo "nvidia-smi is already installed."
    fi
else
    echo "GPU not enabled for this instance."
fi

# Extract deployment files
DIR=~/deploy
mkdir -p "$DIR" && cd "$DIR"
curl http://metadata.google.internal/computeMetadata/v1/instance/attributes/deploy-tar -H "Metadata-Flavor: Google"| base64 --decode > deploy.tar.gz
tar -xzvf deploy.tar.gz && rm deploy.tar.gz

# Write config file
curl http://metadata.google.internal/computeMetadata/v1/instance/attributes/secret-config -H "Metadata-Flavor: Google" | base64 --decode > config.json
chmod 600 config.json

sudo docker compose up -d
