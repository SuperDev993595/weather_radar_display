#!/bin/bash

# Comprehensive Nginx debugging and fix script
echo "🔍 Nginx Debug and Fix Script"
echo "=============================="

# Function to print colored output
print_status() {
    echo -e "\033[0;32m[INFO]\033[0m $1"
}

print_error() {
    echo -e "\033[0;31m[ERROR]\033[0m $1"
}

print_warning() {
    echo -e "\033[0;33m[WARNING]\033[0m $1"
}

# 1. Check if Nginx is installed
print_status "Checking Nginx installation..."
if ! command -v nginx &> /dev/null; then
    print_error "Nginx is not installed!"
    print_status "Installing Nginx..."
    sudo apt update
    sudo apt install -y nginx
else
    print_status "Nginx is installed: $(nginx -v 2>&1)"
fi

# 2. Check Nginx process status
print_status "Checking Nginx process status..."
if pgrep nginx > /dev/null; then
    print_warning "Nginx processes are running. Stopping them..."
    sudo pkill nginx
    sleep 2
fi

# 3. Check for port conflicts
print_status "Checking for port 80 conflicts..."
if sudo netstat -tlnp | grep :80; then
    print_warning "Port 80 is in use. Checking what's using it..."
    sudo lsof -i :80
fi

# 4. Check Nginx configuration syntax
print_status "Testing Nginx configuration syntax..."
if sudo nginx -t 2>&1; then
    print_status "✅ Nginx configuration syntax is valid"
else
    print_error "❌ Nginx configuration has syntax errors"
    print_status "Detailed error output:"
    sudo nginx -t 2>&1
fi

# 5. Check for missing directories
print_status "Checking required directories..."
sudo mkdir -p /var/log/nginx
sudo mkdir -p /var/lib/nginx
sudo mkdir -p /etc/nginx/sites-available
sudo mkdir -p /etc/nginx/sites-enabled

# 6. Set proper permissions
print_status "Setting proper permissions..."
sudo chown -R www-data:www-data /var/log/nginx/
sudo chown -R www-data:www-data /var/lib/nginx/
sudo chmod -R 755 /var/log/nginx/
sudo chmod -R 755 /var/lib/nginx/

# 7. Check for broken symlinks
print_status "Checking for broken symlinks..."
sudo find /etc/nginx/sites-enabled/ -type l ! -exec test -e {} \; -delete

# 8. Create a minimal working configuration if needed
print_status "Creating backup of current configuration..."
sudo cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.backup

# 9. Test with a minimal configuration
print_status "Testing with minimal configuration..."
cat > /tmp/nginx-minimal.conf << 'EOF'
events {
    worker_connections 1024;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;
    
    server {
        listen 80 default_server;
        server_name _;
        location / {
            return 200 "Nginx is working!";
            add_header Content-Type text/plain;
        }
    }
}
EOF

if sudo nginx -t -c /tmp/nginx-minimal.conf; then
    print_status "✅ Minimal configuration works"
else
    print_error "❌ Even minimal configuration fails"
    print_status "This indicates a deeper system issue"
fi

# 10. Check system resources
print_status "Checking system resources..."
echo "Memory usage:"
free -h
echo "Disk space:"
df -h /
echo "Load average:"
uptime

# 11. Check for SELinux or AppArmor issues
print_status "Checking security modules..."
if command -v getenforce &> /dev/null; then
    echo "SELinux status: $(getenforce)"
fi

if command -v aa-status &> /dev/null; then
    echo "AppArmor status:"
    sudo aa-status
fi

# 12. Try to start Nginx with detailed logging
print_status "Attempting to start Nginx with detailed logging..."
sudo nginx -g "daemon off;" &
NGINX_PID=$!
sleep 3

if kill -0 $NGINX_PID 2>/dev/null; then
    print_status "✅ Nginx started successfully!"
    kill $NGINX_PID
    print_status "Starting Nginx as service..."
    sudo systemctl start nginx
    if sudo systemctl is-active --quiet nginx; then
        print_status "✅ Nginx service is now running!"
    else
        print_error "❌ Nginx service failed to start"
    fi
else
    print_error "❌ Nginx failed to start even with detailed logging"
fi

# 13. Final status check
print_status "Final status check..."
sudo systemctl status nginx --no-pager

# 14. Show recent logs
print_status "Recent Nginx logs:"
sudo journalctl -u nginx.service --no-pager -n 20

echo ""
print_status "Debug script completed!"
print_status "If Nginx is still not working, check the logs above for specific error messages."
