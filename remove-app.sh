#!/bin/bash
echo "Removing all application resources..."

docker stop web-container db-container 2>/dev/null
docker rm web-container db-container 2>/dev/null
docker network rm app-network 2>/dev/null
docker volume rm db-data 2>/dev/null

echo "Removed app completely."
