#!/usr/bin/env bash
# Mac: double-click to run the site locally so downloads work.
cd "$(dirname "$0")" || exit 1
PORT=8080
( sleep 1; open "http://localhost:$PORT/index.html" ) &
if command -v python3 >/dev/null 2>&1; then python3 -m http.server $PORT
elif command -v php >/dev/null 2>&1; then php -S localhost:$PORT
elif command -v ruby >/dev/null 2>&1; then ruby -run -e httpd . -p $PORT
else echo "Please install Python 3 or use VS Code Live Server."; read -n 1; fi
