#!/bin/bash

# Tar the deployment files
cd ../deploy

# Enumerate them so that OS-specific files are not included
tar -czvf ../procure/deploy.tar.gz docker-compose.yaml fluent-bit.conf redis.conf &> /dev/null
