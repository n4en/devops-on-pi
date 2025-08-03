# n8n Setup Guide with ngrok Integration

This guide will help you set up n8n with ngrok for external access and Box OAuth integration.

## Table of Contents
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [n8n Docker Compose Setup](#n8n-docker-compose-setup)
- [Basic ngrok Setup](#basic-ngrok-setup)
- [n8n with ngrok Integration](#n8n-with-ngrok-integration)
- [Box OAuth Configuration](#box-oauth-configuration)
- [Persistent ngrok Setup](#persistent-ngrok-setup)
- [Advanced Docker Compose Configuration](#advanced-docker-compose-configuration)
- [Troubleshooting](#troubleshooting)

## Prerequisites

- Raspberry Pi or Linux system
- Docker and Docker Compose installed
- ngrok account (free tier available)
- Box Developer Account (for OAuth integration)

## Installation

### 1. Install Docker and Docker Compose

First, ensure Docker and Docker Compose are installed:

```bash
# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Add user to docker group
sudo usermod -aG docker $USER

# Install Docker Compose
sudo apt-get update
sudo apt-get install docker-compose-plugin

# Verify installation
docker --version
docker compose version
```

### 2. Install ngrok

Install ngrok via Snap:

```bash
snap install ngrok
```

Alternatively, download from [ngrok.com](https://ngrok.com/downloads/linux?tab=snap)

### 3. Configure ngrok

Add your authtoken (get one from [ngrok.com](https://ngrok.com)):

```bash
ngrok config add-authtoken <your-ngrok-token>
```

## n8n Docker Compose Setup

### 1. Create n8n Directory

```bash
mkdir n8n
cd n8n
```

### 2. Create Docker Compose File

Create a `docker-compose.yml` file:

```yaml
version: '3.8'

services:
  n8n:
    image: n8nio/n8n:latest
    container_name: n8n
    restart: unless-stopped
    ports:
      - "5678:5678"
    environment:
      - N8N_BASIC_AUTH_ACTIVE=true
      - N8N_BASIC_AUTH_USER=admin
      - N8N_BASIC_AUTH_PASSWORD=your-secure-password
      - N8N_HOST=0.0.0.0
      - N8N_PORT=5678
      - N8N_PROTOCOL=https
      - WEBHOOK_URL=https://your-custom-domain.ngrok-free.app
      - N8N_ENCRYPTION_KEY=your-32-character-encryption-key
      - NODE_ENV=production
      - DB_TYPE=sqlite
      - DB_SQLITE_DATABASE=/home/node/.n8n/database.sqlite
    volumes:
      - n8n_data:/home/node/.n8n
    networks:
      - n8n_network

volumes:
  n8n_data:
    driver: local

networks:
  n8n_network:
    driver: bridge
```

### 3. Generate Encryption Key

Generate a secure 32-character encryption key:

```bash
openssl rand -hex 16
```

Replace `your-32-character-encryption-key` in the docker-compose.yml with the generated key.

### 4. Start n8n

```bash
docker compose up -d
```

### 5. Verify n8n is Running

```bash
docker compose ps
docker compose logs n8n
```

Access n8n at: `http://localhost:5678`

**Default credentials:**
- Username: `admin`
- Password: `your-secure-password` (as set in docker-compose.yml)

## Basic ngrok Setup

Test your ngrok installation:

```bash
ngrok http 80
```

This will create a tunnel to your local port 80. You should see a URL like `https://xxxx-xx-xx-xxx-xx.ngrok-free.app`

## n8n with ngrok Integration

### Step 1: Start ngrok Tunnel

If your n8n runs on port 5678, start the tunnel:

```bash
ngrok http --domain=your-custom-domain.ngrok-free.app 5678
```

**Important:** 
- Replace `your-custom-domain` with your actual ngrok domain
- Keep this terminal open. The tunnel will forward external traffic to your local n8n instance.

### Step 2: Update n8n Environment

The webhook URL is already configured in the `docker-compose.yml` file. If you need to update it:

```yaml
environment:
  - WEBHOOK_URL=https://your-custom-domain.ngrok-free.app
```

After making changes, restart n8n:

```bash
docker compose down
docker compose up -d
```

## Box OAuth Configuration

### Step 1: Box Developer Console Setup

1. Go to [Box Developer Console](https://app.box.com/developers/console)
2. Create a new app or select an existing one
3. Navigate to OAuth2 settings
4. Set the redirect URI:

```
https://your-custom-domain.ngrok-free.app/rest/oauth2-credential/callback
```

5. Save your changes

### Step 2: Configure Event Types

Ensure the following event types are allowed in your Box app:
- File uploads
- Folder creation
- File modifications
- File deletions

## Persistent ngrok Setup

For production use, you'll want ngrok to run automatically. Here are three options:

### Option 1: Simple Background Process

Run ngrok with `nohup` for persistence:

```bash
nohup ngrok http --domain=your-custom-domain.ngrok-free.app 5678 > ngrok.log 2>&1 &
```

**Commands:**
- Check if running: `ps aux | grep ngrok`
- View logs: `cat ngrok.log`
- Stop process: `pkill ngrok`

### Option 2: Systemd Service (Recommended)

Create a systemd service for automatic startup:

#### 1. Create the startup script

```bash
sudo nano /usr/local/bin/start-ngrok.sh
```

Add the following content:

```bash
#!/bin/bash
ngrok http --domain=your-custom-domain.ngrok-free.app 5678
```

Make it executable:

```bash
chmod +x /usr/local/bin/start-ngrok.sh
```

#### 2. Create systemd service

```bash
sudo nano /etc/systemd/system/ngrok.service
```

Add the following content:

```ini
[Unit]
Description=ngrok tunnel for n8n
After=network.target

[Service]
ExecStart=/usr/local/bin/start-ngrok.sh
Restart=always
User=pi
Environment=NGROK_AUTHTOKEN=your-ngrok-token

[Install]
WantedBy=multi-user.target
```

#### 3. Enable and start the service

```bash
sudo systemctl daemon-reload
sudo systemctl enable ngrok
sudo systemctl start ngrok
```

#### 4. Check service status

```bash
sudo systemctl status ngrok
```

## Troubleshooting

### Common Issues

1. **ngrok not starting**
   - Check if authtoken is configured: `ngrok config check`
   - Verify domain is available and not in use

2. **Box OAuth not working**
   - Verify redirect URL is exactly: `https://your-custom-domain.ngrok-free.app/rest/oauth2-credential/callback`
   - Check that event types are properly configured in Box Developer Console

3. **n8n not accessible**
   - Ensure ngrok tunnel is running: `ps aux | grep ngrok`
   - Check n8n is running on port 5678
   - Verify firewall settings

### Useful Commands

```bash
# Check ngrok status
ps aux | grep ngrok

# View ngrok logs
tail -f ngrok.log

# Restart ngrok service
sudo systemctl restart ngrok

# Check n8n logs
docker-compose logs n8n
```

## Additional Resources

- [n8n Docker Compose Examples](https://github.com/n8n-io/n8n-hosting/tree/main/docker-compose) - Official n8n hosting configurations
- [n8n Documentation](https://docs.n8n.io/) - Complete n8n documentation
- [ngrok Documentation](https://ngrok.com/docs)
- [Box API Documentation](https://developer.box.com/)

## Advanced Docker Compose Configuration

For production use, consider these additional configurations:

### PostgreSQL Database (Recommended for Production)

```yaml
version: '3.8'

services:
  n8n:
    image: n8nio/n8n:latest
    container_name: n8n
    restart: unless-stopped
    ports:
      - "5678:5678"
    environment:
      - N8N_BASIC_AUTH_ACTIVE=true
      - N8N_BASIC_AUTH_USER=admin
      - N8N_BASIC_AUTH_PASSWORD=your-secure-password
      - N8N_HOST=0.0.0.0
      - N8N_PORT=5678
      - N8N_PROTOCOL=https
      - WEBHOOK_URL=https://your-custom-domain.ngrok-free.app
      - N8N_ENCRYPTION_KEY=your-32-character-encryption-key
      - NODE_ENV=production
      - DB_TYPE=postgresdb
      - DB_POSTGRESDB_HOST=postgres
      - DB_POSTGRESDB_PORT=5432
      - DB_POSTGRESDB_DATABASE=n8n
      - DB_POSTGRESDB_USER=n8n
      - DB_POSTGRESDB_PASSWORD=your-db-password
    volumes:
      - n8n_data:/home/node/.n8n
    depends_on:
      - postgres
    networks:
      - n8n_network

  postgres:
    image: postgres:15
    container_name: n8n-postgres
    restart: unless-stopped
    environment:
      - POSTGRES_DB=n8n
      - POSTGRES_USER=n8n
      - POSTGRES_PASSWORD=your-db-password
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - n8n_network

volumes:
  n8n_data:
    driver: local
  postgres_data:
    driver: local

networks:
  n8n_network:
    driver: bridge
```

### Redis for Queue Management (Optional)

Add Redis service for better performance:

```yaml
  redis:
    image: redis:7-alpine
    container_name: n8n-redis
    restart: unless-stopped
    networks:
      - n8n_network
```

And add Redis environment variables to n8n:

```yaml
environment:
  - QUEUE_BULL_REDIS_HOST=redis
  - QUEUE_BULL_REDIS_PORT=6379
```

## Security Notes

- Keep your ngrok authtoken secure
- Regularly update ngrok and n8n
- Monitor ngrok logs for suspicious activity
- Consider using ngrok's paid plans for production use