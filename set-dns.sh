#!/bin/bash

# Set DNS to Cloudflare 1.1.1.1 and Quad9 9.9.9.9 for all network services
# IPv4 - Primary: 1.1.1.1 (Cloudflare), Backup: 1.0.0.1 (Cloudflare)
# IPv4 - Secondary: 9.9.9.9 (Quad9), Backup: 149.112.112.112 (Quad9)
# IPv6 - Cloudflare: 2606:4700:4700::1111, 2606:4700:4700::1001
# IPv6 - Quad9: 2620:fe::fe, 2620:fe::9

echo "Setting DNS servers for all network services..."
echo "IPv4 Primary: 1.1.1.1 (Cloudflare)"
echo "IPv4 Backup: 1.0.0.1 (Cloudflare)"
echo "IPv4 Secondary: 9.9.9.9 (Quad9)"
echo "IPv4 Backup: 149.112.112.112 (Quad9)"
echo "IPv6: 2606:4700:4700::1111, 2606:4700:4700::1001, 2620:fe::fe, 2620:fe::9"
echo ""

# Get all network services (excluding the header line with asterisk)
networksetup -listallnetworkservices | grep -v "An asterisk" | while IFS= read -r service; do
    echo "Configuring DNS for: $service"
    sudo networksetup -setdnsservers "$service" 1.1.1.1 1.0.0.1 9.9.9.9 149.112.112.112 2606:4700:4700::1111 2606:4700:4700::1001 2620:fe::fe 2620:fe::9
done

echo ""
echo "DNS configuration complete!"
echo ""
echo "Verifying DNS settings:"
scutil --dns | grep 'nameserver\[[0-9]*\]'
