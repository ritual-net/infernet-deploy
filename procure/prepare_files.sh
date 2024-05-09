#!/bin/bash

cd ../deploy

# Tar the deployment files
# Enumerate them so that OS-specific files are not included
tar -czvf ../procure/deploy.tar.gz docker-compose.yaml fluent-bit.conf redis.conf \
    &> /dev/null;

# GPU deployment files. Rename docker-compose-gpu.yaml to docker-compose.yaml
# on the fly using sym links
mkdir temp_links

# Create symbolic links with the new names
ln -s "$(pwd)/docker-compose-gpu.yaml" temp_links/docker-compose.yaml
ln -s "$(pwd)/fluent-bit.conf" temp_links/fluent-bit.conf
ln -s "$(pwd)/redis.conf" temp_links/redis.conf

# Tar the files using the symbolic links
tar -czvhf ../procure/deploy-gpu.tar.gz -C temp_links docker-compose.yaml fluent-bit.conf redis.conf

# Clean up the symbolic links and the temporary directory
rm -rf temp_links
