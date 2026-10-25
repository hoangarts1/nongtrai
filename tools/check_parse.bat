@echo off
REM Parse check: opens the project headless and quits. Exit code 0 = no script parse errors.
REM Usage:  set GODOT=C:\Godot\godot.exe   then   tools\check_parse.bat
REM If GODOT is not set, falls back to `godot` on PATH.
setlocal
if "%GODOT%"=="" if exist "D:\godot\Godot_v4.7.2-stable_win64.exe" set GODOT=D:\godot\Godot_v4.7.2-stable_win64.exe
if "%GODOT%"=="" set GODOT=godot
cd /d "%~dp0\.."
echo [check_parse] using: %GODOT%
powershell -NoProfile -ExecutionPolicy Bypass -File tools\run_godot_bounded.ps1 -Godot "%GODOT%" -Arguments "--version" -OutputPath "%TEMP%\the_life_version.log"
powershell -NoProfile -ExecutionPolicy Bypass -File tools\run_godot_bounded.ps1 -Godot "%GODOT%" -Arguments "--headless --path . --quit" -OutputPath "%TEMP%\the_life_parse.log"
if errorlevel 1 (
  echo [check_parse] FAILED
  exit /b 1
)
powershell -NoProfile -Command "if (Select-String -Path '%TEMP%\the_life_parse.log.stdout','%TEMP%\the_life_parse.log.stderr' -Pattern 'SCRIPT ERROR|Parse Error|Failed to load script|ERROR:' -Quiet) { exit 1 }"
if errorlevel 1 (
  echo [check_parse] ERROR TEXT FOUND
  exit /b 1
)
echo [check_parse] OK
endlocal
