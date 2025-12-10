#!/bin/bash
set -e

APP_NAME="MyCrystApp"
INSTALL_DIR="\$HOME/.manaca-local"

echo "Creating installer..."

cat > installer.run <<'EOF'
#!/bin/bash
set -e

APP_NAME="MyCrystApp"
INSTALL_DIR="$HOME/.manaca-local"

echo "Installing $APP_NAME to $INSTALL_DIR..."

rm -rf "$INSTALL_DIR"
mkdir -p "$INSTALL_DIR"

echo "Extracting files..."
TAIL_LINE=$(awk '/^__ARCHIVE_BELOW__/ {print NR + 1; exit 0; }' "$0")
tail -n +$TAIL_LINE "$0" | tar xz -C "$INSTALL_DIR"

echo "Installing desktop icon..."
mkdir -p "$HOME/.local/share/applications"
cp "$INSTALL_DIR/MyCrystApp.desktop" "$HOME/.local/share/applications/"

echo "Installation complete!"
echo "You can launch $APP_NAME from your applications menu."

exit 0

__ARCHIVE_BELOW__
EOF

echo "Packing app into installer..."
tar czf - \
  backend frontend venv run_prod.sh MyCrystApp.desktop icon.png \
  >> installer.run

chmod +x installer.run

echo "Installer created: installer.run"
