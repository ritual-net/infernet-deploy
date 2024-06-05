#! /bin/bash

# Install docker
cd ~/
sudo apt update
sudo apt-get update
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common jq
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
sudo apt install -y docker-ce
sudo apt install -y awscli

# Create a shell script for subsequent boots
cat << 'EOF' > $HOME/run_on_reboot.sh
#!/bin/bash

# Fetch node IPs from metadata and save to file
aws ssm get-parameter --name "node-ips-${cluster-name}" --with-decryption --query "Parameter.Value" --output text --region "${region}" > $HOME/ips.txt

# Prune existing router container
CONTAINER_NAME="router"
container_ids=$(docker ps -a --filter "name=$CONTAINER_NAME" -q)
if [ -z "$container_ids" ]; then
    echo "No containers '$CONTAINER_NAME' found."
else
    docker stop $container_ids
    docker rm $container_ids
fi

# Run the container
sudo docker run -d -p 4000:4000 --name router -v $HOME/ips.txt:/app/ips.txt --restart on-failure ritualnetwork/infernet-router:1.0.0
EOF

# Add the script to cron to run at reboot
chmod +x $HOME/run_on_reboot.sh
(crontab -l 2>/dev/null; echo "@reboot $HOME/run_on_reboot.sh") | crontab -

# Execute script for initial setup
$HOME/run_on_reboot.sh
