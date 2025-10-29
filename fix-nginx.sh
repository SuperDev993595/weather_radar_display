#!/bin/bash

# Quick Nginx troubleshooting and fix script
# Run this if Nginx fails to start

echo "🔧 Nginx Troubleshooting Script"
echo "================================"

# Check if Nginx is running
echo "1. Checking Nginx status..."
sudo systemctl status nginx --no-pager

echo ""
echo "2. Testing Nginx configuration..."
if sudo nginx -t; then
    echo "✅ Nginx configuration is valid"
else
    echo "❌ Nginx configuration has errors"
    echo "Checking error details..."
    sudo nginx -t 2>&1
fi

echo ""
echo "3. Checking for syntax errors in sites-enabled..."
for file in /etc/nginx/sites-enabled/*; do
    if [ -f "$file" ]; then
        echo "Checking: $file"
        sudo nginx -t -c "$file" 2>&1 || echo "Error in $file"
    fi
done

echo ""
echo "4. Checking Nginx error logs..."
sudo tail -10 /var/log/nginx/error.log

echo ""
echo "5. Attempting to fix common issues..."

# Remove any broken symlinks
echo "Removing broken symlinks..."
sudo find /etc/nginx/sites-enabled/ -type l ! -exec test -e {} \; -delete

# Ensure proper permissions
echo "Setting proper permissions..."
sudo chown -R www-data:www-data /var/log/nginx/
sudo chmod -R 755 /var/log/nginx/

# Test configuration again
echo ""
echo "6. Testing configuration after fixes..."
if sudo nginx -t; then
    echo "✅ Configuration is now valid"
    echo "Attempting to restart Nginx..."
    sudo systemctl restart nginx
    if sudo systemctl is-active --quiet nginx; then
        echo "✅ Nginx is now running successfully!"
    else
        echo "❌ Nginx still failed to start"
        echo "Check logs: sudo journalctl -xeu nginx.service"
    fi
else
    echo "❌ Configuration still has errors"
    echo "Manual intervention required"
fi

echo ""
echo "7. Final status check..."
sudo systemctl status nginx --no-pager
