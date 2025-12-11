#!/bin/bash
set -e

echo "Building React frontend..."
cd frontend
npm install
npm run build
cd ..

echo "Copying React build to backend/static..."
rm -rf backend/static
mkdir -p backend/static
cp -r frontend/build backend/static

echo "Installing Python dependencies into venv..."
python3 -m venv venv
source venv/bin/activate
pip install -r backend/requirements.txt

echo "Production build complete."
