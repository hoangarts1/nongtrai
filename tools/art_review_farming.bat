@echo off
setlocal
cd /d "%~dp0\.."
if "%GODOT%"=="" if exist "D:\godot\Godot_v4.7.2-stable_win64.exe" set GODOT=D:\godot\Godot_v4.7.2-stable_win64.exe
if "%GODOT%"=="" set GODOT=godot
powershell -NoProfile -ExecutionPolicy Bypass -File tools\run_godot_bounded.ps1 -Godot "%GODOT%" -Arguments "-s --path . tools/art/chibi/farming_art_review_runner.gd" -OutputPath "%TEMP%\the_life_farming_art_review.log"
if errorlevel 1 exit /b %ERRORLEVEL%
findstr /C:"SCRIPT ERROR" /C:"Parse Error" /C:"Failed to load script" /C:"ERROR:" "%TEMP%\the_life_farming_art_review.log.stdout" "%TEMP%\the_life_farming_art_review.log.stderr" >nul
if errorlevel 2 (
	echo [farming_art_review] REVIEW LOG UNAVAILABLE
	exit /b 1
)
if not errorlevel 1 (
	echo [farming_art_review] ERROR TEXT FOUND
	exit /b 1
)
call tools\capture_chibi_farming.bat
if errorlevel 1 exit /b %ERRORLEVEL%
exit /b 0
