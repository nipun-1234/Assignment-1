#!/bin/bash
echo "Stopping app..."

docker stop web-container db-container 2>/dev/null
docker rm web-container db-container 2>/dev/null

echo "App stopped. Data remains preserved in persistent volume."
