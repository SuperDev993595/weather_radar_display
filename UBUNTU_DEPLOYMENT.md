# Ubuntu VPS Deployment Guide

This guide will help you deploy the Weather Radar Display application on an Ubuntu VPS without GUI.

## Prerequisites

- Ubuntu 20.04+ VPS
- Root or sudo access
- Domain name or IP address (we'll use 213.136.72.33)

## Quick Deployment

1. **Clone the repository on your VPS:**
   ```bash
   git clone https://github.com/SuperDev993595/weather_radar_display.git
   cd weather_radar_display
   ```

2. **Make the deployment script executable and run it:**
   ```bash
   chmod +x deploy-ubuntu.sh
   ./deploy-ubuntu.sh
   ```

3. **Follow the prompts and run the PM2 startup command when prompted.**

## Manual Deployment Steps

If you prefer to deploy manually or need to troubleshoot:

### 1. System Setup

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Node.js 18.x
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# Install PM2 and serve globally
sudo npm install -g pm2 serve

# Install Nginx
sudo apt install -y nginx
```

### 2. Application Setup

```bash
# Create application directory
sudo mkdir -p /var/www/weather-radar
sudo chown -R $USER:$USER /var/www/weather-radar

# Copy files
cp -r . /var/www/weather-radar/
cd /var/www/weather-radar

# Install dependencies
npm install
cd server && npm install && cd ..
cd client && npm install && cd ..

# Build frontend
cd client && npm run build && cd ..
```

### 3. Configure Nginx

```bash
# Copy Nginx configuration
sudo cp nginx.conf /etc/nginx/sites-available/weather-radar
sudo ln -sf /etc/nginx/sites-available/weather-radar /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default

# Test and restart Nginx
sudo nginx -t
sudo systemctl restart nginx
sudo systemctl enable nginx
```

### 4. Start Application

```bash
# Start with PM2
pm2 start ecosystem.config.js
pm2 save
pm2 startup  # Follow the instructions

# Check status
pm2 status
```

### 5. Configure Firewall

```bash
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw --force enable
```

## Architecture

The deployment uses:

- **Frontend**: React app served by `serve` on port 3003
- **Backend**: Node.js/Express API on port 5003
- **Reverse Proxy**: Nginx on port 80
- **Process Manager**: PM2 for process management

## Access Points

- **Main Application**: http://213.136.72.33
- **API Endpoints**: http://213.136.72.33/api/
- **Health Check**: http://213.136.72.33/api/health

## Management Commands

```bash
# View application status
pm2 status

# View logs
pm2 logs

# Restart application
pm2 restart all

# Stop application
pm2 stop all

# Monitor resources
pm2 monit

# View Nginx status
sudo systemctl status nginx

# View Nginx logs
sudo tail -f /var/log/nginx/error.log
sudo tail -f /var/log/nginx/access.log
```

## Troubleshooting

### Application won't start
```bash
# Check PM2 logs
pm2 logs

# Check if ports are in use
sudo netstat -tlnp | grep :3003
sudo netstat -tlnp | grep :5003
```

### Nginx issues
```bash
# Test Nginx configuration
sudo nginx -t

# Check Nginx status
sudo systemctl status nginx

# Restart Nginx
sudo systemctl restart nginx
```

### Permission issues
```bash
# Fix ownership
sudo chown -R $USER:$USER /var/www/weather-radar
```

## SSL/HTTPS Setup (Optional)

To add SSL certificate with Let's Encrypt:

```bash
# Install Certbot
sudo apt install certbot python3-certbot-nginx

# Get SSL certificate
sudo certbot --nginx -d your-domain.com

# Auto-renewal
sudo crontab -e
# Add: 0 12 * * * /usr/bin/certbot renew --quiet
```

## Monitoring

The application includes:
- PM2 process monitoring
- Nginx access/error logs
- Application-specific logs in `/var/www/weather-radar/logs/`

## Updates

To update the application:

```bash
cd /var/www/weather-radar
git pull
npm install
cd server && npm install && cd ..
cd client && npm run build && cd ..
pm2 restart all
```

## Security Notes

- The application runs on non-root user
- Firewall is configured to only allow necessary ports
- Nginx provides additional security layer
- Consider setting up fail2ban for additional security
