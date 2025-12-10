#!/bin/bash
export MYAPP_DEV=1

echo "[DEV MODE] Starting Flask backend..."
( cd backend && python3 app.py ) &

echo "[DEV MODE] Starting React frontend..."
( cd frontend && npm start )
