@echo off
title Wishcraft - download real photos
cd /d "%~dp0"
echo.
echo  Downloading the real photos listed in images\image-list.txt ...
echo  (free Unsplash photos - needs an internet connection)
echo.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\get-real-images.ps1"
echo.
pause
