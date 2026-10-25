@echo off
REM Parse check: opens the project headless and quits. Exit code 0 = no script parse errors.
REM Usage:  set GODOT=C:\Godot\godot.exe   then   tools\check_parse.bat
REM If GODOT is not set, falls back to `godot` on PATH.
setlocal
if "%GODOT%"=="" set GODOT=godot
cd /d "%~dp0\.."
echo [check_parse] using: %GODOT%
"%GODOT%" --version
"%GODOT%" --headless --path . --quit
if errorlevel 1 (
  echo [check_parse] FAILED
  exit /b 1
)
echo [check_parse] OK
endlocal
