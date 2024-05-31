#! /bin/bash

# Directory for deployment files
DIR=~/deploy

# Script to setup a node in an GCP cluster. Startup scripts on GCP run at EVERY boot,
# so no need to set up a cron job to bring services back up on reboot. However, we need
# to ensure that installation of docker, libraries, and GPU drivers only happen once at
# the time of node creation. Therefore, we will check if the /root/deploy/config.json
# file exists and if not, we will assume this is the first boot and install everything.

if [ ! -f "$DIR/config.json" ]; then
    cd ~/
    sudo apt update
    sudo apt-get update
    sudo apt install -y apt-transport-https ca-certificates curl software-properties-common

    # Install docker
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
    sudo apt install -y docker-ce docker-compose-plugin

    # Install GPU driver if necessary
    GPU="${gpu}"
    if [ "$GPU" = "true" ]; then
        if ! nvidia-smi &> /dev/null
        then
            echo "nvidia-smi did not succeed, installing NVIDIA drivers..."

            # Install driver
            sudo apt-get -y install nvidia-driver-470

            # Install container toolkit
            curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
            && curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
                sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
                sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
            sudo apt-get update
            sudo apt-get install -y nvidia-container-toolkit
            sudo systemctl restart docker
        else
            echo "nvidia-smi is already installed."
        fi
    else
        echo "GPU not enabled for this instance."
    fi
fi

# Extract deployment files
mkdir -p "$DIR" && cd "$DIR"
curl http://metadata.google.internal/computeMetadata/v1/instance/attributes/deploy-tar -H "Metadata-Flavor: Google"| base64 --decode > deploy.tar.gz
tar -xzvf deploy.tar.gz && rm deploy.tar.gz

# Write config file
curl http://metadata.google.internal/computeMetadata/v1/instance/attributes/secret-config -H "Metadata-Flavor: Google" | base64 --decode > config.json
chmod 600 config.json

sudo docker compose up -d
