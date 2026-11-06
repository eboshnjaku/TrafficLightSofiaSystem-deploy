@echo off
setlocal
title Traffic-Light Control (Sofia)
cd /d "%~dp0"

REM =============== SETTINGS ===============
set "PORT=8080"
set "LINK=WIFI"
REM  LINK: WIFI = the lights talk to this laptop over Wi-Fi (ESP-01 module, no cable).
REM        USB  = the lights are plugged into this laptop with the USB cable.
set "COM_PORT="
REM  COM_PORT (USB only): leave EMPTY to auto-detect the controller board.
REM  Only set it (e.g. set "COM_PORT=COM5") if auto-detect ever picks the wrong one.
REM =======================================

if not exist "TrafficLight.Api.exe" (
  echo  [X] Program files are missing. Run Update.bat, or re-copy the folder.
  echo.
  pause
  exit /b 1
)

REM stop any previous run so the ports are free
taskkill /F /IM TrafficLight.Api.exe >nul 2>&1

if /I "%LINK%"=="USB" goto :usb

REM ---------------- Wi-Fi: start the MQTT broker (hidden) ----------------
if not exist "mosquitto\mosquitto.exe" (
  echo  [X] The Wi-Fi broker files are missing ^(mosquitto folder^). Run Update.bat.
  echo      Or set LINK=USB in this file to use the USB cable instead.
  echo.
  pause
  exit /b 1
)
taskkill /F /IM mosquitto.exe >nul 2>&1
powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -FilePath '%~dp0mosquitto\mosquitto.exe' -ArgumentList '-c','mosquitto.conf' -WorkingDirectory '%~dp0mosquitto' -WindowStyle Hidden"
REM wait (max 10 s) until the broker is listening, so the app doesn't race it
powershell -NoProfile -ExecutionPolicy Bypass -Command "$t=(Get-Date).AddSeconds(10); while((Get-Date) -lt $t){ if(Get-NetTCPConnection -LocalPort 1883 -State Listen -ErrorAction SilentlyContinue){ exit 0 }; Start-Sleep -Milliseconds 300 }; exit 1"
if errorlevel 1 (
  echo  [!] The Wi-Fi broker did not start. See mosquitto\mosquitto.log
  echo.
)

set "LAPTOP_IP="
for /f "usebackq delims=" %%I in (`powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0find-ip.ps1"`) do set "LAPTOP_IP=%%I"
if not defined LAPTOP_IP set "LAPTOP_IP=NOT-CONNECTED-TO-ANY-NETWORK"

set "Device__Mode=Hardware"
set "Device__MqttHost=127.0.0.1"
set "Device__MqttPort=1883"
set "LINK_INFO=Lights over Wi-Fi  -  this laptop's IP: %LAPTOP_IP%"
goto :run

REM ---------------- USB cable ----------------
:usb
REM Auto-detect the Nucleo's USB port (ST-Link Virtual COM Port) unless one is set above.
if not defined COM_PORT (
  for /f "usebackq delims=" %%P in (`powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0find-com.ps1"`) do set "COM_PORT=%%P"
)
if not defined COM_PORT (
  set "COM_PORT=COM3"
  echo  [!] Could not auto-detect the board. Falling back to COM3.
  echo      If the lights do not respond, open this file in Notepad and set COM_PORT
  echo      to the port shown in Device Manager ^> Ports.
  echo.
)
set "Device__Mode=Serial"
set "Device__SerialPort=%COM_PORT%"
set "LINK_INFO=Lights on %COM_PORT% (USB cable)"

:run
set "ASPNETCORE_URLS=http://localhost:%PORT%"
set "ASPNETCORE_ENVIRONMENT=Production"
set "Database__Provider=Sqlite"
set "SecurityLab__LiveLoginFeed=true"
set "SecurityLab__AllowAnonymousControl=true"
set "Defense__Profile=Off"

echo ============================================================
echo    Traffic-Light Control Platform
echo    %LINK_INFO%
echo    Web at http://localhost:%PORT%
echo ============================================================
if /I not "%LINK%"=="USB" (
  echo  Wi-Fi: the ESP-01 must be programmed with MQTT_HOST = %LAPTOP_IP%
  echo         and this laptop must be on the same Wi-Fi as the lights.
  echo         First run: if Windows Firewall asks about "mosquitto", tick BOTH
  echo         Private and Public networks and click Allow.
)
echo.
echo  Keep this window OPEN while you use the app.
echo  To stop: run Stop-TrafficLight.bat ^(this also stops the Wi-Fi broker^)
echo.

REM open the browser a few seconds after the server starts
start "" cmd /c "timeout /t 4 >nul & start http://localhost:%PORT%/"

TrafficLight.Api.exe
