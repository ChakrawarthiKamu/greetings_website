@echo off
title Wishcraft - update download files
cd /d "%~dp0"
echo.
echo  Updating the download copies of your poster images ...
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\build-download-files.ps1"
echo.
pause
