@echo off
title Traffic-Light Control - Stop
taskkill /F /IM TrafficLight.Api.exe >nul 2>&1
taskkill /F /IM mosquitto.exe >nul 2>&1
echo Traffic-Light Control has been stopped.
timeout /t 2 >nul
