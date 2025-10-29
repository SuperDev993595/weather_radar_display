#!/bin/bash

# Weather Radar Display - Ubuntu Deployment Script
# Run this script on your Ubuntu VPS to deploy the application

set -e  # Exit on any error

echo "🚀 Starting Weather Radar Display deployment on Ubuntu..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    print_warning "Running as root. Consider using a non-root user for better security."
fi

# Update system packages
print_status "Updating system packages..."
sudo apt update && sudo apt upgrade -y

# Install Node.js 18.x
print_status "Installing Node.js 18.x..."
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# Install PM2 globally
print_status "Installing PM2 process manager..."
sudo npm install -g pm2

# Install serve for static file serving
print_status "Installing serve for static file serving..."
sudo npm install -g serve

# Install Nginx
print_status "Installing Nginx..."
sudo apt install -y nginx

# Create application directory
APP_DIR="/var/www/weather-radar"
print_status "Creating application directory at $APP_DIR..."
sudo mkdir -p $APP_DIR
sudo chown -R $USER:$USER $APP_DIR

# Copy application files
print_status "Copying application files..."
cp -r . $APP_DIR/
cd $APP_DIR

# Create logs directory
print_status "Creating logs directory..."
mkdir -p logs

# Install dependencies
print_status "Installing root dependencies..."
npm install

print_status "Installing server dependencies..."
cd server && npm install && cd ..

print_status "Installing client dependencies..."
cd client && npm install && cd ..

# Build the frontend
print_status "Building React frontend..."
cd client && npm run build && cd ..

# Configure Nginx
print_status "Configuring Nginx..."
sudo cp nginx.conf /etc/nginx/sites-available/weather-radar
sudo ln -sf /etc/nginx/sites-available/weather-radar /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default

# Test Nginx configuration
print_status "Testing Nginx configuration..."
sudo nginx -t

# Start services with PM2
print_status "Starting application with PM2..."
pm2 start ecosystem.config.js

# Save PM2 configuration
pm2 save

# Setup PM2 to start on boot
pm2 startup
print_warning "Run the command above to enable PM2 startup on boot"

# Restart Nginx
print_status "Restarting Nginx..."
sudo systemctl restart nginx
sudo systemctl enable nginx

# Configure firewall
print_status "Configuring firewall..."
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw --force enable

# Show status
print_status "Deployment completed! 🎉"
echo ""
print_status "Application Status:"
pm2 status
echo ""
print_status "Nginx Status:"
sudo systemctl status nginx --no-pager
echo ""
print_status "Access your application at:"
echo "  - Frontend: http://213.136.72.33"
echo "  - Backend API: http://213.136.72.33/api"
echo ""
print_status "Useful commands:"
echo "  - View logs: pm2 logs"
echo "  - Restart app: pm2 restart all"
echo "  - Stop app: pm2 stop all"
echo "  - Monitor: pm2 monit"
