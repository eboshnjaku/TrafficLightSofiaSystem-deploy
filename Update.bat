@echo off
setlocal
title Traffic-Light Control - Update
cd /d "%~dp0"

where git >nul 2>&1
if errorlevel 1 (
  echo  [X] Git is not installed - cannot download updates.
  echo      Install "Git for Windows", or ask for a fresh copy of the folder.
  echo.
  pause
  exit /b 1
)

echo Stopping the app...
taskkill /F /IM TrafficLight.Api.exe >nul 2>&1

echo Downloading the latest version...
git fetch --depth 1 origin main
if errorlevel 1 (
  echo.
  echo  [X] Update could not download. Check the internet connection and try again.
  echo.
  pause
  exit /b 1
)
git reset --hard origin/main
if errorlevel 1 (
  echo.
  echo  [X] Update could not be applied.
  echo.
  pause
  exit /b 1
)

echo.
echo  [OK] Updated. Start it again with Start-TrafficLight.bat (or the Desktop shortcut).
echo.
pause
