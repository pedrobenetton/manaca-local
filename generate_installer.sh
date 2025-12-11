#!/bin/bash
set -e

APP_NAME="MyCrystApp"
ROOT_DIR="$(pwd)"
INSTALLER="$ROOT_DIR/installer.run"

echo "Creating installer at: $INSTALLER"

# -------------------------------
# Create installer header
# -------------------------------
cat > "$INSTALLER" <<'EOF'
#!/bin/bash
set -e

APP_NAME="MyCrystApp"
INSTALL_DIR="$HOME/.manaca-local"

echo "Installing $APP_NAME to $INSTALL_DIR..."

# Clean previous installation
rm -rf "$INSTALL_DIR"
mkdir -p "$INSTALL_DIR"

echo "Extracting files..."
# Extract everything that comes after __ARCHIVE_BELOW__
TAIL_LINE=$(awk '/^__ARCHIVE_BELOW__/ {print NR + 1; exit 0; }' "$0")
tail -n +$TAIL_LINE "$0" | tar xz -C "$INSTALL_DIR"

# Install desktop launcher
echo "Installing desktop icon..."
mkdir -p "$HOME/.local/share/applications"
cp "$INSTALL_DIR/MyCrystApp.desktop" "$HOME/.local/share/applications/"

echo "Installation complete!"
echo "You can now launch $APP_NAME from your applications menu."

exit 0

__ARCHIVE_BELOW__
EOF

# -------------------------------
# Pack the application contents
# -------------------------------
echo "Packing files into installer..."

# We package the *contents* of manaca-local, not the folder itself
cd "$ROOT_DIR"

tar czf - \
    backend \
    frontend \
    venv \
    run_prod.sh \
    MyCrystApp.desktop \
    icon.png \
    >> "$INSTALLER"

# Make installer executable
chmod +x "$INSTALLER"

echo "Installer created successfully: $INSTALLER"
