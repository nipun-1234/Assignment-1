#!/bin/bash

echo "Preparing app..."

docker network create app-network 2>/dev/null || echo "Network already exists."

docker volume create db-data 2>/dev/null || echo "Volume already exists."

echo "Preparation completed successfully!"
