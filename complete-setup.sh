#!/bin/bash
# Complete ASUS TUF Gaming Setup for Arch Linux
# Run this script when your network connection is stable

set -e

echo "================================================"
echo "  ASUS TUF Gaming A17 Complete Setup Script"
echo "================================================"
echo ""

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Step 1: Installing ASUS Control Tools${NC}"
echo "Installing asusctl (fan/LED control), rog-control-center (GUI), and supergfxctl (GPU switching)..."
yay -S --needed asusctl rog-control-center supergfxctl

echo ""
echo -e "${GREEN}✓ ASUS tools installed${NC}"
echo ""

echo -e "${YELLOW}Step 2: Enabling ASUS Services${NC}"
sudo systemctl enable --now power-profiles-daemon.service
sudo systemctl enable --now supergfxd.service

echo ""
echo -e "${GREEN}✓ Services enabled${NC}"
echo ""

echo -e "${YELLOW}Step 3: Installing KDE Effects${NC}"
echo "Installing krohnkite (dynamic tiling) and forceblur (window blur)..."
yay -S --needed kwin-scripts-krohnkite kwin-effects-forceblur

echo ""
echo -e "${GREEN}✓ KDE effects installed${NC}"
echo ""

echo -e "${YELLOW}Step 4: Testing ASUS Controls${NC}"
echo "Available asusctl commands:"
echo "  - asusctl fan-curve       # Set custom fan curves"
echo "  - asusctl profile -l      # List power profiles"
echo "  - asusctl profile -P Performance  # Set performance mode"
echo "  - asusctl led-mode -l     # List LED modes"
echo "  - rog-control-center      # Open GUI"
echo ""
echo "GPU switching (supergfxctl):"
echo "  - supergfxctl -g          # Get current GPU mode"
echo "  - supergfxctl -m hybrid   # Hybrid mode (both GPUs)"
echo "  - supergfxctl -m integrated  # AMD only (battery save)"
echo "  - supergfxctl -m nvidia   # NVIDIA only (performance)"
echo ""

echo "================================================"
echo -e "${GREEN}Setup Complete!${NC}"
echo "================================================"
echo ""
echo "Next steps:"
echo "1. Reboot your system"
echo "2. Enable KDE effects in System Settings:"
echo "   - Window Management → KWin Scripts → enable Krohnkite"
echo "   - Window Management → Desktop Effects → enable Force Blur"
echo "3. Launch rog-control-center to control fans/RGB"
echo "4. Test gaming with: steam (gamemode + mangohud enabled)"
echo ""
echo "To enable gamemode for a game, right-click game in Steam:"
echo "  Properties → Launch Options → add: gamemoderun mangohud %command%"
echo ""
