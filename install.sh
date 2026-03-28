#!/bin/bash
set -e

# ==============================================================================
# CDS Host Guardian - Unified Installer (v0.1.0)
# ==============================================================================

echo "--------------------------------------------------------"
echo "  CDS Host Guardian: Multi-Layer Security Installer"
echo "--------------------------------------------------------"

# 1. Install Docker Zero-Trust Auth (cds-authz-system)
echo "[+] Step 1: Installing Docker Zero-Trust Authorization System..."
if [ -d "cds-authz-system" ]; then
    cd cds-authz-system
    chmod +x install.sh
    sudo ./install.sh
    cd ..
else
    echo "Error: cds-authz-system directory not found!" >&2
    exit 1
fi

# 2. Install Btrfs Root Hunter (btrfs-root-hunter)
echo ""
echo "[+] Step 2: Installing Btrfs Integrity Protection (Root Hunter)..."
if [ -d "btrfs-root-hunter" ]; then
    cd btrfs-root-hunter
    # Assuming btrfs-root-hunter has its own install script or just needs binary placement
    if [ -f "install.sh" ]; then
        chmod +x install.sh
        sudo ./install.sh
    else
        # Fallback manual installation for btrfs-root-hunter
        sudo cp btrfs-root-hunter.sh /usr/local/bin/btrfs-root-hunter
        sudo chmod +x /usr/local/bin/btrfs-root-hunter
        echo "Btrfs-root-hunter script installed in /usr/local/bin/."
    fi
    cd ..
else
    echo "Error: btrfs-root-hunter directory not found!" >&2
    exit 1
fi

echo ""
echo "--------------------------------------------------------"
echo "  Installation Complete!"
echo "--------------------------------------------------------"
echo ""
echo "Next steps:"
echo "1. Configure Docker Auth Plugin in /etc/docker/daemon.json"
echo "2. Restart Docker: sudo systemctl restart docker"
echo "3. Run Btrfs Hunter: sudo btrfs-root-hunter"
echo ""
