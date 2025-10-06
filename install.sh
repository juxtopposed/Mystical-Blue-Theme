#!/bin/bash
set -e

echo "[*] Installing Mystical-Blue (Jux) Theme..."

BASE_DIR="$(cd "$(dirname "$0")" && pwd)"
COLOR_DIR="$HOME/.local/share/color-schemes"
AURORAE_DIR="$HOME/.local/share/aurorae/themes"
PLASMA_DIR="$HOME/.local/share/plasma/desktoptheme"
KVANTUM_DIR="$HOME/.config/Kvantum"
ROFI_DIR="$HOME/.config/rofi"
ROFI_IMG_DIR="$HOME/.local/share/jux-rofi-images"
FONT_DIR="$HOME/.local/share/fonts"

mkdir -p "$COLOR_DIR" "$AURORAE_DIR" "$PLASMA_DIR" "$KVANTUM_DIR" "$ROFI_DIR" "$ROFI_IMG_DIR" "$FONT_DIR"

install_if_missing() {
    local bin="$1"
    shift
    local pkgs="$@"
    if ! command -v "$bin" >/dev/null 2>&1; then
        echo "[*] Installing missing dependency: $pkgs"
        sudo apt update
        sudo apt install -y $pkgs
    else
        echo "[=] Found dependency: $bin"
    fi
}

install_if_missing git git
install_if_missing cmake cmake
install_if_missing make build-essential
install_if_missing unzip unzip
install_if_missing wget wget

cp "$BASE_DIR/JuxTheme.colors" "$COLOR_DIR/" && echo "[+] Installed color scheme: JuxTheme"
tar -xzf "$BASE_DIR/JuxDeco.tar.gz" -C "$AURORAE_DIR/" && echo "[+] Installed Aurorae decoration: JuxDeco"
tar -xzf "$BASE_DIR/JuxPlasma.tar.gz" -C "$PLASMA_DIR/" && echo "[+] Installed Plasma theme: JuxPlasma"

if [ -f "$BASE_DIR/NoMansSkyJux.tar.gz" ]; then
    tar -xzf "$BASE_DIR/NoMansSkyJux.tar.gz" -C "$KVANTUM_DIR/"
    echo "[+] Installed Kvantum theme: NoMansSkyJux"
fi

cp "$BASE_DIR/rofi/config.rasi" "$ROFI_DIR/"
echo "[+] Installed Rofi config"
cp -r "$BASE_DIR/images/"* "$ROFI_IMG_DIR/" 2>/dev/null || true
echo "[+] Installed Rofi images"

echo "[*] Checking JetBrainsMono fonts..."
FONT_COUNT=$(fc-list | grep -i "JetBrainsMono" | wc -l)

if [ "$FONT_COUNT" -lt 20 ]; then
    echo "[!] JetBrainsMono incomplete ($FONT_COUNT fonts found). Installing full set..."
    LOCAL_FONT_DIR=$(find "$BASE_DIR" -maxdepth 2 -type d -name "JetBrainsMono-*")
    if [ -n "$LOCAL_FONT_DIR" ]; then
        echo "[*] Installing from local: $LOCAL_FONT_DIR"
        find "$LOCAL_FONT_DIR" -type f -name "*.ttf" -exec cp {} "$FONT_DIR/" \;
    else
        echo "[*] Downloading JetBrainsMono from JetBrains..."
        TMP_FONT=$(mktemp -d)
        wget -qO "$TMP_FONT/JetBrainsMono.zip" "https://download.jetbrains.com/fonts/JetBrainsMono-2.304.zip"
        unzip -qq "$TMP_FONT/JetBrainsMono.zip" -d "$TMP_FONT"
        find "$TMP_FONT" -type f -name "*.ttf" -exec cp {} "$FONT_DIR/" \;
    fi
    fc-cache -fv > /dev/null
    echo "[+] JetBrainsMono fonts installed"
else
    echo "[=] JetBrainsMono already installed ($FONT_COUNT files)"
fi

PLASMA_VERSION=$(plasmashell --version 2>/dev/null | grep -o '[0-9]\+' | head -1 || echo 0)
if [ "$PLASMA_VERSION" -ge 6 ]; then
    echo "[=] Detected Plasma $PLASMA_VERSION → using Bismuth (tiling)"
    TILING="bismuth"
else
    echo "[=] Detected Plasma $PLASMA_VERSION → using Krohnkite (tiling)"
    TILING="krohnkite"
fi

read -p "Do you want to install the tiling extension ($TILING)? (y/N): " RESP
if [[ "$RESP" =~ ^[Yy]$ ]]; then
    TMP_DIR=$(mktemp -d)
    if [ "$TILING" = "krohnkite" ]; then
        echo "[*] Installing Krohnkite..."
        git clone https://github.com/esjeon/krohnkite.git "$TMP_DIR/krohnkite"
        PLASMAPKG=$(command -v plasmapkg2 || command -v plasmapkg || command -v kpackagetool6 || true)
        if [ -n "$PLASMAPKG" ]; then
            "$PLASMAPKG" --type=KWin/Script -i "$TMP_DIR/krohnkite"
        else
            echo "[!] Could not find plasmapkg tool, skipping Krohnkite"
        fi
    else
        echo "[*] Installing Bismuth..."
        git clone https://github.com/Bismuth-Forge/bismuth.git "$TMP_DIR/bismuth"
        kpackagetool6 --type=KWin/Script -i "$TMP_DIR/bismuth" || echo "[!] Failed to install Bismuth"
    fi
fi

install_if_missing kvantummanager "qt-style-kvantum qt-style-kvantum-themes"

echo ""
echo "======================================="
echo " Mystical-Blue (Jux) Theme Installed 🎉"
echo " Apply via System Settings → Appearance"
echo " For tiling: Enable $TILING in KWin Scripts"
echo "======================================="
