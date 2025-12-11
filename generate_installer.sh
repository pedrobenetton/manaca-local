#!/bin/bash
set -e

APPNAME="MyCrystApp"
VERSION="1.0"
APPDIR="$APPNAME.AppDir"

echo "=== Cleaning previous AppDir ==="
rm -rf "$APPDIR"
mkdir -p "$APPDIR/usr/bin"
mkdir -p "$APPDIR/usr/lib"
mkdir -p "$APPDIR/usr/app"

echo "=== Copying icon ==="
cp icon.png "$APPDIR/"

echo "=== Copying backend, static, venv ==="
cp -r backend "$APPDIR/usr/app/backend"
cp -r venv "$APPDIR/usr/app/venv"

echo "=== Copying React build to backend/static ==="
rm -rf "$APPDIR/usr/app/backend/static/build"
cp -r frontend/build "$APPDIR/usr/app/backend/static/build"

echo "=== Bundling system python interpreter ==="
PYBIN=$(which python3)
PYDIR=$(dirname "$PYBIN")
PYLIB=$(python3 - <<EOF
import sys
import os
print(os.path.dirname(sys.executable))
EOF
)

cp "$PYBIN" "$APPDIR/usr/bin/python3"

echo "=== Copying Python stdlib ==="
cp -r /usr/lib/python3.* "$APPDIR/usr/lib/" || true

echo "=== Creating internal launcher (run_app.sh) ==="
cat << 'EOF' > "$APPDIR/usr/app/run_app.sh"
#!/bin/bash
HERE="$(dirname "$(readlink -f "$0")")"

export PATH="$HERE/venv/bin:$PATH"
export PYTHONPATH="$HERE/backend:$PYTHONPATH"
export MYAPP_DEV=""

PORT=5000
PID_IN_USE=$(lsof -t -i:$PORT)

if [ ! -z "$PID_IN_USE" ]; then
    echo "Port $PORT is in use by PID $PID_IN_USE. Killing it..."
    kill -9 $PID_IN_USE 2>/dev/null
    sleep 0.5
fi

# Start Flask backend
"$HERE/venv/bin/python3" "$HERE/backend/app.py" &
PID=$!

sleep 1
xdg-open http://127.0.0.1:5000

wait $PID
EOF

chmod +x "$APPDIR/usr/app/run_app.sh"

echo "=== Creating AppRun ==="
cat << 'EOF' > "$APPDIR/AppRun"
#!/bin/bash
HERE="$(dirname "$(readlink -f "$0")")"
exec "$HERE/usr/app/run_app.sh"
EOF

chmod +x "$APPDIR/AppRun"

echo "=== Creating .desktop file ==="
cat << EOF > "$APPDIR/mycrystapp.desktop"
[Desktop Entry]
Name=My Crystallography App
Exec=AppRun
Icon=icon
Type=Application
Terminal=false
Categories=Utility;
EOF

echo "=== Building AppImage ==="
if ! command -v appimagetool >/dev/null 2>&1; then
    echo "appimagetool not found. Downloading..."
    wget -O appimagetool https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage
    chmod +x appimagetool
fi

./appimagetool "$APPDIR" "${APPNAME}-${VERSION}.AppImage"

echo "=== Done! ==="
echo "Your AppImage is ready:"
echo "  ${APPNAME}-${VERSION}.AppImage"

