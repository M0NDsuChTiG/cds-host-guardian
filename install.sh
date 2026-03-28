#!/bin/bash
# ==============================================================================
# 🛡️ CDS Host Guardian - Unified Installer (v0.2.0)
# ==============================================================================
# This script orchestrates the installation of the entire security stack:
# 1. CDS AuthZ System (Docker Zero-Trust)
# 2. Btrfs Root Hunter (Filesystem Integrity)
# ==============================================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

echo -e "${BLUE}--------------------------------------------------------${NC}"
echo -e "${GREEN}  CDS Host Guardian: Multi-Layer Security Installer${NC}"
echo -e "${BLUE}--------------------------------------------------------${NC}"

# 0. Check Prerequisites
log_info "Checking prerequisites..."
for cmd in go docker cosign btrfs; do
    if ! command -v $cmd &> /dev/null; then
        log_error "$cmd is not installed. Please install it first."
        exit 1
    fi
done
log_success "All prerequisites met."

# 1. Initialize Submodules if needed
if [ ! -f "cds-authz-system/go.mod" ]; then
    log_warn "Submodules not found. Initializing..."
    git submodule update --init --recursive
    log_success "Submodules initialized."
fi

# 2. Install CDS AuthZ System
log_info "Step 1: Installing Docker Zero-Trust Authorization System..."
if [ -d "cds-authz-system" ]; then
    pushd cds-authz-system > /dev/null
    chmod +x install.sh
    ./install.sh
    popd > /dev/null
    log_success "CDS AuthZ System installed."
else
    log_error "cds-authz-system directory not found!"
    exit 1
fi

# 3. Install Btrfs Root Hunter
log_info "Step 2: Installing Btrfs Integrity Protection (Root Hunter)..."
if [ -d "btrfs-root-hunter" ]; then
    # Install binaries/scripts to /usr/local/bin
    sudo install btrfs-root-hunter/btrfs-root-hunter.sh /usr/local/bin/btrfs-root-hunter
    sudo install btrfs-root-hunter/btrfs_magic.sh /usr/local/bin/btrfs_magic
    log_success "Btrfs Hunter scripts installed in /usr/local/bin/."
else
    log_warn "btrfs-root-hunter directory not found. Skipping."
fi

# 4. Post-Installation Configuration Helper
echo -e "\n${BLUE}--------------------------------------------------------${NC}"
echo -e "${YELLOW}  Post-Installation Configuration${NC}"
echo -e "${BLUE}--------------------------------------------------------${NC}"

DOCKER_CONFIG="/etc/docker/daemon.json"
if [ -f "$DOCKER_CONFIG" ]; then
    if grep -q "cds-authz" "$DOCKER_CONFIG"; then
        log_success "Docker is already configured with cds-authz plugin."
    else
        log_warn "Docker is NOT configured with the authorization plugin."
        echo -e "To enable it, add the following to ${BLUE}$DOCKER_CONFIG${NC}:"
        echo -e "${GREEN}{\n  \"authorization-plugins\": [\"cds-authz\"]\n}${NC}"
    fi
else
    log_warn "Docker config file $DOCKER_CONFIG not found."
    echo -e "You may need to create it and add the plugin configuration."
fi

echo -e "\n${GREEN}Final Steps:${NC}"
echo -e "1. ${BLUE}sudo systemctl restart docker${NC}"
echo -e "2. ${BLUE}cds-cli --help${NC} (Manage trust policies)"
echo -e "3. ${BLUE}sudo btrfs-root-hunter --help${NC} (Check filesystem integrity)"
echo -e "\n${GREEN}Installation Complete! Visit our Security Lab for more: ${NC}https://m0ndsuchtig.github.io/cds-host-guardian/"
