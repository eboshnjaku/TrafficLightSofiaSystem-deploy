@echo off
setlocal
cd /d "%~dp0"
echo Creating Desktop shortcuts for Start and Stop...
powershell -NoProfile -ExecutionPolicy Bypass -Command "$app='%~dp0'; $w=New-Object -ComObject WScript.Shell; $d=[Environment]::GetFolderPath('Desktop'); foreach($x in @(@('Start Traffic Lights','Start-TrafficLight.bat',137),@('Stop Traffic Lights','Stop-TrafficLight.bat',109))){ $s=$w.CreateShortcut((Join-Path $d ($x[0]+'.lnk'))); $s.TargetPath=(Join-Path $app $x[1]); $s.WorkingDirectory=$app; $s.IconLocation=('shell32.dll,'+$x[2]); $s.Save() }"
echo.
echo Done. On your Desktop you now have:
echo    "Start Traffic Lights"    and    "Stop Traffic Lights"
echo.
echo (The app folder can stay wherever it is - the shortcuts point back to it.)
echo.
pause
