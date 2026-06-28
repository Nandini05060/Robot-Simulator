@echo off
title Blucursor Phone Preview Portal
echo ====================================================
echo   Blucursor Phone Preview Portal
echo ====================================================
echo.
echo [1/2] Starting local web server on port 3000...
start /b python -m http.server 3000 >nul 2>&1
timeout /t 2 >nul
echo.
echo [2/2] Connecting to public tunnel...
echo.
echo Copy the link starting with "https://" and open it on your phone!
echo Close this window to stop the server when you are done.
echo ----------------------------------------------------
ssh -R 80:localhost:3000 nokey@localhost.run
