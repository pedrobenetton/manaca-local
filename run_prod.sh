#!/bin/bash
unset MYAPP_DEV
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$DIR/venv/bin/activate"
python3 "$DIR/backend/app.py" &
sleep 2
xdg-open http://localhost:5000
wait
