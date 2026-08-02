#!/bin/bash

echo "Running app..."

docker run -d \
  --name db-container \
  --network app-network \
  --restart unless-stopped \
  -v db-data:/var/lib/postgresql/data \
  -e POSTGRES_USER=myuser \
  -e POSTGRES_PASSWORD=mypassword \
  -e POSTGRES_DB=mydatabase \
  postgres:15-alpine

docker run -d \
  --name adminer-container \
  --network app-network \
  --restart unless-stopped \
  -p 8080:8080 \
  -e ADMINER_DEFAULT_SERVER=db-container \
  adminer

echo ""
echo "Application Started Successfully!"
echo "Open: http://localhost:8080"
