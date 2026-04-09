#!/bin/bash

# Setup script with Dropbear 2019 version
set -e

echo "======================================"
echo "Installing with Dropbear 2019 Version"
echo "======================================"

# Update system
apt-get update -y
apt-get upgrade -y
apt-get install -y build-essential zlib1g-dev wget curl

# Create temp directory
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

# Download and compile Dropbear 2019.78 (last 2019 version)
echo "Downloading Dropbear 2019.78..."
wget https://matt.ucc.asn.au/dropbear/releases/dropbear-2019.78.tar.bz2

# Extract
echo "Extracting Dropbear..."
tar -xjf dropbear-2019.78.tar.bz2
cd dropbear-2019.78

# Configure and compile
echo "Configuring and compiling Dropbear 2019..."
./configure --prefix=/usr/local
make
make install

# Create init.d startup script
echo "Setting up Dropbear service..."
cat > /etc/init.d/dropbear << 'EOF'
#!/bin/bash
### BEGIN INIT INFO
# Provides:          dropbear
# Required-Start:    $syslog
# Required-Stop:     $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Dropbear SSH Server
# Description:       Dropbear SSH Server
### END INIT INFO

case "$1" in
  start)
    /usr/local/sbin/dropbear -p 22
    ;;
  stop)
    pkill -f /usr/local/sbin/dropbear
    ;;
  restart)
    $0 stop
    $0 start
    ;;
esac
EOF

chmod +x /etc/init.d/dropbear
update-rc.d dropbear defaults

# Clean up
cd /
rm -rf "$TEMP_DIR"

echo "======================================"
echo "Dropbear 2019.78 installed successfully!"
echo "======================================"