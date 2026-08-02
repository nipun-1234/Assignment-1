# Docker Web Application Deployment

## Deployment Requirements
- Docker Engine (v20.10 or higher)
- Bash Terminal (Linux/Ubuntu)

## Application Description
This project deploys a 2-tier application with a PostgreSQL database and an Adminer web management interface.

## Network and Volume Details
- **Network (`app-network`):** Custom bridge network for isolated inter-container communication.
- **Volume (`db-data`):** Named volume mapped to `/var/lib/postgresql/data` for persistent database storage.

## Container Details
1. **`db-container`**
   - Image: `postgres:15-alpine`
   - Role: Database Engine
   - Environment Variables: `POSTGRES_USER`, `POSTGRES_PASSWORD`, `POSTGRES_DB`
2. **`adminer-container`**
   - Image: `adminer`
   - Role: Web Interface (Port 8080)

## Workflow Instructions

### 1. Prepare
```bash
./prepare-app.sh
