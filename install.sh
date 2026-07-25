#!/bin/bash
# ==========================================================
#  Terminal & Desktop Environment Installer
#  Nord theme + Dracula cursor + video wallpaper
# ==========================================================
#  Run:  chmod +x install.sh && ./install.sh
# ==========================================================

set -euo pipefail

# --- Colors for output ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${SCRIPT_DIR}/config"
BACKUP_DIR="$HOME/.config-backups/terminal-$(date +%Y%m%d-%H%M%S)"

log()  { echo -e "${GREEN}[✓]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }
err()  { echo -e "${RED}[✗]${NC} $1"; }
info() { echo -e "${CYAN}[·]${NC} $1"; }

# --- Sanity check ---
if [ ! -d "$CONFIG_DIR" ]; then
    err "Config directory not found at $CONFIG_DIR"
    err "Make sure install.sh is in the same folder as the config/ directory."
    exit 1
fi

echo ""
echo -e "${CYAN}╔══════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║   Terminal & Desktop Environment Installer       ║${NC}"
echo -e "${CYAN}║   Nord + Dracula cursor + Video wallpaper        ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════════╝${NC}"
echo ""

# ==========================================================
# 1. INSTALL SYSTEM PACKAGES
# ==========================================================
info "Checking system packages..."

PACKAGES_NEEDED=()

command -v alacritty &>/dev/null || PACKAGES_NEEDED+=(alacritty)
command -v starship  &>/dev/null || PACKAGES_NEEDED+=(starship)
command -v tmux      &>/dev/null || PACKAGES_NEEDED+=(tmux)
command -v picom     &>/dev/null || PACKAGES_NEEDED+=(picom)
command -v mpv       &>/dev/null || PACKAGES_NEEDED+=(mpv)
command -v i3        &>/dev/null || PACKAGES_NEEDED+=(i3-wm)
command -v i3status  &>/dev/null || PACKAGES_NEEDED+=(i3status)
command -v fzf       &>/dev/null || PACKAGES_NEEDED+=(fzf)
command -v eza       &>/dev/null || PACKAGES_NEEDED+=(eza)
command -v bat       &>/dev/null || PACKAGES_NEEDED+=(bat)
command -v rg        &>/dev/null || PACKAGES_NEEDED+=(ripgrep)
command -v fd        &>/dev/null || PACKAGES_NEEDED+=(fd)
command -v delta     &>/dev/null || PACKAGES_NEEDED+=(git-delta)
command -v dust      &>/dev/null || PACKAGES_NEEDED+=(dust)
command -v duf       &>/dev/null || PACKAGES_NEEDED+=(duf)
command -v btm       &>/dev/null || PACKAGES_NEEDED+=(bottom)
command -v procs     &>/dev/null || PACKAGES_NEEDED+=(procs)
command -v neofetch  &>/dev/null || { command -v fastfetch &>/dev/null || PACKAGES_NEEDED+=(fastfetch); }
command -v xsetroot  &>/dev/null || PACKAGES_NEEDED+=(xorg-xsetroot)
command -v i3lock    &>/dev/null || PACKAGES_NEEDED+=(i3lock)
command -v dunstctl  &>/dev/null || PACKAGES_NEEDED+=(dunst)
command -v j4-dmenu-desktop &>/dev/null || PACKAGES_NEEDED+=(j4-dmenu-desktop)

# Check for JetBrainsMono Nerd Font
if ! fc-list | grep -qi "JetBrainsMono Nerd"; then
    PACKAGES_NEEDED+=(ttf-jetbrains-mono-nerd)
fi

if [ ${#PACKAGES_NEEDED[@]} -gt 0 ]; then
    warn "The following packages are missing: ${PACKAGES_NEEDED[*]}"
    info "Installing via pacman..."
    sudo pacman -S --noconfirm --needed "${PACKAGES_NEEDED[@]}" || {
        err "pacman install failed. Install these manually: ${PACKAGES_NEEDED[*]}"
    }
else
    log "All system packages already installed"
fi

# ==========================================================
# 2. BACKUP EXISTING CONFIG
# ==========================================================
info "Creating backup at $BACKUP_DIR..."
mkdir -p "$BACKUP_DIR"

backup_if_exists() {
    local src="$1"
    local dest="$BACKUP_DIR/$(basename "$src")"
    if [ -e "$src" ]; then
        cp -r "$src" "$dest"
        info "  Backed up $(basename "$src")"
    fi
}

backup_if_exists "$HOME/.bashrc_hacker"
backup_if_exists "$HOME/.tmux.conf"
backup_if_exists "$HOME/.config/starship.toml"
backup_if_exists "$HOME/.config/alacritty/alacritty.toml"
backup_if_exists "$HOME/.config/i3/config"
backup_if_exists "$HOME/.config/i3/set_wallpaper.sh"
backup_if_exists "$HOME/.config/i3/launch_alacritty_monitors.sh"
backup_if_exists "$HOME/.config/picom/picom.conf"
backup_if_exists "$HOME/.config/i3status/config"
backup_if_exists "$HOME/.config/gtk-3.0/settings.ini"
backup_if_exists "$HOME/.icons/default"
backup_if_exists "$HOME/.icons/Dracula-cursors"

log "Backup complete"

# ==========================================================
# 3. INSTALL CONFIG FILES
# ==========================================================
info "Installing config files..."

# --- bashrc_hacker ---
cp "$CONFIG_DIR/bashrc_hacker" "$HOME/.bashrc_hacker"
log "Installed .bashrc_hacker"

# Ensure .bashrc sources it
if ! grep -q 'source ~/.bashrc_hacker' "$HOME/.bashrc" 2>/dev/null; then
    echo -e '\n# Load Hacker Terminal Profile\nsource ~/.bashrc_hacker' >> "$HOME/.bashrc"
    log "Added bashrc_hacker source to .bashrc"
else
    log ".bashrc already sources bashrc_hacker"
fi

# --- tmux ---
cp "$CONFIG_DIR/tmux.conf" "$HOME/.tmux.conf"
log "Installed .tmux.conf"

# --- starship ---
mkdir -p "$HOME/.config"
cp "$CONFIG_DIR/starship.toml" "$HOME/.config/starship.toml"
log "Installed starship.toml"

# --- alacritty ---
mkdir -p "$HOME/.config/alacritty"
cp "$CONFIG_DIR/alacritty.toml" "$HOME/.config/alacritty/alacritty.toml"
log "Installed alacritty.toml"

# Clone alacritty themes if not present
if [ ! -d "$HOME/.config/alacritty/alacritty-theme" ]; then
    info "Cloning alacritty themes..."
    git clone https://github.com/alacritty/alacritty-theme.git \
        "$HOME/.config/alacritty/alacritty-theme" 2>/dev/null || \
        warn "Could not clone alacritty themes (not critical)"
fi

# --- i3 ---
mkdir -p "$HOME/.config/i3"
cp "$CONFIG_DIR/i3.config" "$HOME/.config/i3/config"
cp "$CONFIG_DIR/set_wallpaper.sh" "$HOME/.config/i3/set_wallpaper.sh"
cp "$CONFIG_DIR/launch_alacritty_monitors.sh" "$HOME/.config/i3/launch_alacritty_monitors.sh"
chmod +x "$HOME/.config/i3/set_wallpaper.sh"
chmod +x "$HOME/.config/i3/launch_alacritty_monitors.sh"
log "Installed i3 config + scripts"

# --- picom ---
mkdir -p "$HOME/.config/picom"
cp "$CONFIG_DIR/picom.conf" "$HOME/.config/picom/picom.conf"
log "Installed picom.conf"

# --- i3status ---
mkdir -p "$HOME/.config/i3status"
cp "$CONFIG_DIR/i3status.conf" "$HOME/.config/i3status/config"
log "Installed i3status config"

# ==========================================================
# 4. INSTALL DRACULA CURSOR THEME
# ==========================================================
info "Installing Dracula cursor theme..."

if [ -d "$HOME/.icons/Dracula-cursors/cursors" ]; then
    log "Dracula cursor theme already installed"
else
    CURSOR_URL="https://github.com/dracula/gtk/releases/download/v4.0.0/Dracula-cursors.tar.xz"
    CURSOR_TMP="/tmp/Dracula-cursors-$$.tar.xz"

    info "Downloading Dracula cursors..."
    if curl -fsSL -o "$CURSOR_TMP" "$CURSOR_URL"; then
        mkdir -p "$HOME/.icons"
        tar xf "$CURSOR_TMP" -C "$HOME/.icons/"
        # The archive extracts to "Dracula-cursors/"
        rm -f "$CURSOR_TMP"
        log "Dracula cursor theme installed to ~/.icons/Dracula-cursors"
    else
        err "Failed to download Dracula cursor theme"
        warn "You can manually download from: $CURSOR_URL"
    fi
fi

# Set as default cursor theme
mkdir -p "$HOME/.icons/default"
cp "$CONFIG_DIR/default-cursor-index.theme" "$HOME/.icons/default/index.theme"
log "Set Dracula as default cursor"

# GTK cursor setting
mkdir -p "$HOME/.config/gtk-3.0"
cp "$CONFIG_DIR/gtk-3.0-settings.ini" "$HOME/.config/gtk-3.0/settings.ini"
log "Configured GTK cursor theme"

# ==========================================================
# 5. SET CURSOR ENVIRONMENT VARIABLES
# ==========================================================
info "Setting cursor environment variables..."

# Add to .profile if not already there
if ! grep -q 'XCURSOR_THEME=Dracula-cursors' "$HOME/.profile" 2>/dev/null; then
    cat >> "$HOME/.profile" << 'EOF'

# Dracula cursor theme
export XCURSOR_THEME=Dracula-cursors
export XCURSOR_SIZE=24
EOF
    log "Added cursor env vars to .profile"
else
    log "Cursor env vars already in .profile"
fi

# Add to Xresources if not already there
if ! grep -q 'Xcursor.theme.*Dracula' "$HOME/.Xresources" 2>/dev/null; then
    cat >> "$HOME/.Xresources" << 'EOF'

! Dracula Cursor Theme
Xcursor.theme: Dracula-cursors
Xcursor.size: 24
EOF
    log "Added cursor theme to .Xresources"
else
    log "Cursor theme already in .Xresources"
fi

# Merge Xresources now
if command -v xrdb &>/dev/null; then
    xrdb -merge "$HOME/.Xresources" 2>/dev/null && log "Merged .Xresources" || warn "Could not merge .Xresources (no DISPLAY?)"
fi

# ==========================================================
# 6. INSTALL STARSHIP (if not present)
# ==========================================================
if ! command -v starship &>/dev/null; then
    info "Installing Starship prompt..."
    curl -sS https://starship.rs/install.sh | sh -s -- -y || warn "Starship install failed"
else
    log "Starship already installed"
fi

# ==========================================================
# 7. VERIFY WALLPAPER VIDEO
# ==========================================================
if [ ! -f "$HOME/Pictures/nfs_wallpaper.mp4" ]; then
    warn "Video wallpaper not found at ~/Pictures/nfs_wallpaper.mp4"
    warn "Place your wallpaper video there for the video wallpaper to work."
else
    log "Wallpaper video found at ~/Pictures/nfs_wallpaper.mp4"
fi

# ==========================================================
# DONE
# ==========================================================
echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║   Installation complete!                         ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "  Backup saved to: ${CYAN}${BACKUP_DIR}${NC}"
echo ""
echo -e "  ${YELLOW}To apply changes:${NC}"
echo -e "    1. Open a new terminal (font + prompt changes)"
echo -e "    2. Reload i3:  ${CYAN}i3-msg restart${NC}"
echo -e "    3. Or log out and log back in for full effect"
echo ""
