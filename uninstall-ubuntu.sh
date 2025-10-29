#!/bin/bash

# Weather Radar Display - Ubuntu Uninstall Script
# Run this script on your Ubuntu VPS to completely remove the application

set -e  # Exit on any error

echo "🗑️ Starting Weather Radar Display uninstall on Ubuntu..."

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
    print_warning "Running as root. This is fine for uninstall."
fi

# 1. Stop and Remove PM2 Processes
print_status "Stopping and removing PM2 processes..."
if command -v pm2 &> /dev/null; then
    pm2 stop all 2>/dev/null || true
    pm2 delete all 2>/dev/null || true
    pm2 unstartup 2>/dev/null || true
    print_status "PM2 processes removed"
else
    print_warning "PM2 not found, skipping PM2 cleanup"
fi

# 2. Remove Application Directory
print_status "Removing application directory..."
if [ -d "/var/www/weather-radar" ]; then
    sudo rm -rf /var/www/weather-radar
    print_status "Application directory removed"
else
    print_warning "Application directory not found at /var/www/weather-radar"
fi

# 3. Remove Nginx Configuration
print_status "Removing Nginx configuration..."
if [ -f "/etc/nginx/sites-enabled/weather-radar" ]; then
    sudo rm -f /etc/nginx/sites-enabled/weather-radar
    print_status "Nginx site configuration removed"
fi

if [ -f "/etc/nginx/sites-available/weather-radar" ]; then
    sudo rm -f /etc/nginx/sites-available/weather-radar
    print_status "Nginx available configuration removed"
fi

# Restore default Nginx configuration if it exists
if [ -f "/etc/nginx/sites-available/default" ]; then
    sudo ln -sf /etc/nginx/sites-available/default /etc/nginx/sites-enabled/ 2>/dev/null || true
    print_status "Default Nginx configuration restored"
fi

# Restart Nginx
print_status "Restarting Nginx..."
sudo systemctl restart nginx 2>/dev/null || print_warning "Could not restart Nginx"

# 4. Remove Application Logs
print_status "Removing application logs..."
sudo rm -rf /var/log/weather-radar 2>/dev/null || true
sudo rm -rf /var/www/weather-radar/logs 2>/dev/null || true
print_status "Application logs removed"

# 5. Clean Up Global Dependencies (Optional)
print_warning "Do you want to remove global dependencies? (y/N)"
read -r response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    print_status "Removing global dependencies..."
    
    if command -v pm2 &> /dev/null; then
        sudo npm uninstall -g pm2 2>/dev/null || true
        print_status "PM2 removed"
    fi
    
    if command -v serve &> /dev/null; then
        sudo npm uninstall -g serve 2>/dev/null || true
        print_status "Serve removed"
    fi
    
    print_warning "Do you want to remove Node.js and Nginx? (y/N)"
    read -r response2
    if [[ "$response2" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        sudo apt remove -y nginx nginx-common 2>/dev/null || true
        sudo apt remove -y nodejs npm 2>/dev/null || true
        print_status "Node.js and Nginx removed"
    fi
else
    print_status "Keeping global dependencies"
fi

# 6. Reset Firewall (Optional)
print_warning "Do you want to reset firewall rules? (y/N)"
read -r response3
if [[ "$response3" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    print_status "Resetting firewall..."
    sudo ufw --force reset 2>/dev/null || true
    print_status "Firewall reset"
else
    print_status "Keeping firewall rules"
fi

# 7. Clean up any remaining processes
print_status "Cleaning up remaining processes..."
sudo pkill -f "weather-radar" 2>/dev/null || true
sudo pkill -f "serve.*build" 2>/dev/null || true

# 8. Verify removal
print_status "Verifying removal..."

echo ""
print_status "Checking PM2 processes:"
pm2 list 2>/dev/null || print_warning "PM2 not available"

echo ""
print_status "Checking application directory:"
if [ -d "/var/www/weather-radar" ]; then
    print_error "Application directory still exists!"
else
    print_status "✅ Application directory removed"
fi

echo ""
print_status "Checking Nginx configuration:"
if [ -f "/etc/nginx/sites-enabled/weather-radar" ]; then
    print_error "Nginx configuration still exists!"
else
    print_status "✅ Nginx configuration removed"
fi

echo ""
print_status "Checking ports:"
PORTS_IN_USE=$(sudo netstat -tlnp 2>/dev/null | grep -E ":(3003|5003|80)" | wc -l)
if [ "$PORTS_IN_USE" -eq 0 ]; then
    print_status "✅ All application ports are free"
else
    print_warning "Some ports are still in use:"
    sudo netstat -tlnp 2>/dev/null | grep -E ":(3003|5003|80)" || true
fi

echo ""
print_status "Uninstall completed! 🎉"
echo ""
print_status "Summary:"
echo "  - PM2 processes: Removed"
echo "  - Application files: Removed"
echo "  - Nginx configuration: Removed"
echo "  - Application logs: Removed"
echo "  - Global dependencies: $(if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then echo "Removed"; else echo "Kept"; fi)"
echo "  - Firewall rules: $(if [[ "$response3" =~ ^([yY][eE][sS]|[yY])$ ]]; then echo "Reset"; else echo "Kept"; fi)"
echo ""
print_status "The Weather Radar Display application has been completely removed from your system."
