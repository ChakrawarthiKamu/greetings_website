@echo off
title Wishcraft - local website server
cd /d "%~dp0"
echo.
echo  Starting the website at http://localhost:8080  (keep this window open)
echo  Close this window to stop it.
echo.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\server.ps1"
pause
