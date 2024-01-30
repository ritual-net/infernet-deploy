#! /bin/bash

# Install docker
cd ~/
sudo apt update
sudo apt-get update
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common jq
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
sudo apt install -y docker-ce

# Home directory
HOME=~/
cd "$HOME"

# Fetch node IPs from metadata and save to file
curl -H "Metadata-Flavor: Google" \
     "http://metadata.google.internal/computeMetadata/v1/instance/attributes/node-ips" \
     > $HOME/ips.txt

CONTAINER_NAME="router"

# Find all containers with the specified name pattern
container_ids=$(docker ps -a --filter "name=$CONTAINER_NAME" -q)

# Remove container with the same name
if [ -z "$container_ids" ]; then
    echo "No containers '$CONTAINER_NAME' found."
else
    # Stop the container (if running)
    docker stop $container_ids

    # Remove the container
    docker rm $container_ids
fi

# Run the container
sudo docker run -d -p 4000:4000 --name router -v ./ips.txt:/app/ips.txt --restart on-failure ritualnetwork/infernet-router:0.1.0
