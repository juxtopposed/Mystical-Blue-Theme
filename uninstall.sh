#!/usr/bin/env bash
# Mystical-Blue (Jux) Theme - uninstaller
#
# Removes ONLY what install.sh copied for this theme.
# It never touches: system packages, fonts, or anything it cannot
# tie to this theme. A tiling extension is removed only if you say yes.
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: ./uninstall.sh [options]

  -y, --yes           Do not ask for confirmation (tiling extension is
                      still kept unless --remove-tiling is also given)
      --remove-tiling Also remove the tiling extension install.sh may have added
      --keep-tiling   Never remove the tiling extension, and do not ask
  -h, --help          Show this help
USAGE
}

ASSUME_YES=0
TILING_MODE="ask" # ask | yes | no

for arg in "$@"; do
  case "$arg" in
  -y | --yes) ASSUME_YES=1 ;;
  --remove-tiling) TILING_MODE="yes" ;;
  --keep-tiling) TILING_MODE="no" ;;
  -h | --help)
    usage
    exit 0
    ;;
  *)
    echo "Unknown option: $arg" >&2
    usage >&2
    exit 1
    ;;
  esac
done

# --- Safety checks -----------------------------------------------------
if [ "$(id -u)" -eq 0 ]; then
  echo "[!] Do not run this as root or with sudo." >&2
  echo "    The theme lives in your own home folder." >&2
  exit 1
fi
if [ -z "${HOME:-}" ] || [ ! -d "$HOME" ]; then
  echo "[!] HOME is not set to a valid folder. Aborting." >&2
  exit 1
fi

BASE_DIR="$(cd "$(dirname "$0")" && pwd)"

# Same locations install.sh uses
COLOR_DIR="$HOME/.local/share/color-schemes"
AURORAE_DIR="$HOME/.local/share/aurorae/themes"
PLASMA_DIR="$HOME/.local/share/plasma/desktoptheme"
KVANTUM_DIR="$HOME/.config/Kvantum"
ROFI_DIR="$HOME/.config/rofi"
ROFI_IMG_DIR="$HOME/.local/share/jux-rofi-images"
KWIN_SCRIPTS_DIR="$HOME/.local/share/kwin/scripts"

confirm() {
  # $1 = question. Default answer is No.
  if [ "$ASSUME_YES" -eq 1 ]; then
    return 0
  fi
  if [ ! -t 0 ]; then
    return 1
  fi
  local reply
  read -r -p "$1 [y/N]: " reply
  [[ "$reply" =~ ^[Yy]$ ]]
}

safe_remove() {
  # Only ever removes one exact path, and only inside $HOME.
  local target="$1"
  case "$target" in
  "$HOME"/?*) ;;
  *)
    echo "[!] Refusing to remove a path outside HOME: $target" >&2
    return 1
    ;;
  esac
  if [ -e "$target" ] || [ -L "$target" ]; then
    rm -rf -- "$target"
    echo "[-] Removed: $target"
  else
    echo "[=] Not installed (skipping): $target"
  fi
}

echo "[*] Uninstalling Mystical-Blue (Jux) Theme..."

# --- Warn if the theme is still active ---------------------------------
in_use=()
grep -qsE '^ColorScheme=JuxTheme$' "$HOME/.config/kdeglobals" && in_use+=("Colors: JuxTheme")
grep -qsE '^name=JuxPlasma$' "$HOME/.config/plasmarc" && in_use+=("Plasma style: JuxPlasma")
grep -qsE '^theme=__aurorae__svg__JuxDeco$' "$HOME/.config/kwinrc" && in_use+=("Window decoration: JuxDeco")
grep -qsE '^theme=NoMansSkyJux$' "$KVANTUM_DIR/kvantum.kvconfig" && in_use+=("Kvantum style: NoMansSkyJux")

if [ "${#in_use[@]}" -gt 0 ]; then
  echo "[!] This theme is still active in your settings:"
  for item in "${in_use[@]}"; do
    echo "      - $item"
  done
  echo "    Removing it now can leave your desktop with missing styles."
  echo "    Switch to another theme in System Settings -> Appearance first."
  if ! confirm "Remove the files anyway?"; then
    echo "[*] Nothing was removed."
    exit 1
  fi
fi

# --- Theme files -------------------------------------------------------
safe_remove "$COLOR_DIR/JuxTheme.colors"
safe_remove "$AURORAE_DIR/JuxDeco"
safe_remove "$PLASMA_DIR/JuxPlasma"
safe_remove "$KVANTUM_DIR/NoMansSkyJux"
safe_remove "$ROFI_IMG_DIR"

# Rofi config: install.sh overwrote ~/.config/rofi/config.rasi.
# Remove it only if it is still byte-for-byte the theme's own file,
# so a config you edited or wrote yourself is never deleted.
if [ -f "$ROFI_DIR/config.rasi" ]; then
  if [ -f "$BASE_DIR/rofi/config.rasi" ] && cmp -s "$ROFI_DIR/config.rasi" "$BASE_DIR/rofi/config.rasi"; then
    safe_remove "$ROFI_DIR/config.rasi"
  else
    echo "[!] Kept $ROFI_DIR/config.rasi (it differs from the theme's file)"
  fi
fi

# --- Tiling extension (optional, never removed silently) ----------------
# install.sh picks Bismuth on Plasma 6+ and Krohnkite on older versions.
PLASMA_VERSION="$(plasmashell --version 2>/dev/null | grep -o '[0-9]\+' | head -1 || echo 0)"
if [ "${PLASMA_VERSION:-0}" -ge 6 ] 2>/dev/null; then
  TILING="bismuth"
else
  TILING="krohnkite"
fi

if [ "$TILING_MODE" != "no" ] && [ -d "$KWIN_SCRIPTS_DIR/$TILING" ]; then
  remove_tiling=0
  if [ "$TILING_MODE" = "yes" ]; then
    remove_tiling=1
  else
    echo ""
    echo "[?] The tiling extension '$TILING' is installed."
    echo "    install.sh may have added it, but you might also have installed"
    echo "    it yourself earlier, so it is kept unless you say yes."
    # Not covered by --yes: a global "yes" must not delete a tool you may use.
    if [ -t 0 ]; then
      read -r -p "Remove '$TILING' too? [y/N]: " reply
      if [[ "$reply" =~ ^[Yy]$ ]]; then remove_tiling=1; fi
    fi
  fi
  if [ "$remove_tiling" -eq 1 ]; then
    safe_remove "$KWIN_SCRIPTS_DIR/$TILING"
  else
    echo "[=] Kept tiling extension: $TILING"
  fi
fi

echo ""
echo "======================================="
echo " Mystical-Blue (Jux) Theme Uninstalled"
echo " Kept: system packages and fonts"
echo " You can run install.sh again any time"
echo "======================================="
