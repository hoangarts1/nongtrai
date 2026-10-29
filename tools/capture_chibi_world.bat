@echo off
setlocal
cd /d "%~dp0\.."
if "%GODOT%"=="" if exist "D:\godot\Godot_v4.7.2-stable_win64.exe" set GODOT=D:\godot\Godot_v4.7.2-stable_win64.exe
if "%GODOT%"=="" set GODOT=godot
rem Start configured main scene so review uses normal autoload and world wiring.
powershell -NoProfile -ExecutionPolicy Bypass -File tools\run_godot_bounded.ps1 -Godot "%GODOT%" -Arguments "--path . -- --capture-chibi-world" -OutputPath "%TEMP%\the_life_world_scene_capture.log"
if errorlevel 1 exit /b %ERRORLEVEL%
findstr /C:"SCRIPT ERROR" /C:"Parse Error" /C:"Failed to load script" /C:"ERROR:" "%TEMP%\the_life_world_scene_capture.log.stdout" "%TEMP%\the_life_world_scene_capture.log.stderr" >nul
if errorlevel 2 (
	echo [world_scene_capture] CAPTURE LOG UNAVAILABLE
	exit /b 1
)
if not errorlevel 1 (
	echo [world_scene_capture] ERROR TEXT FOUND
	exit /b 1
)
exit /b 0
