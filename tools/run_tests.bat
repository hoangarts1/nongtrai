@echo off
REM Runs: (1) parse check, (2) the unit-test framework headless.
REM Task 0.1 of the roadmap fills in step 2 with the REAL command for the framework you chose
REM (GUT or gdUnit4 - pick ONE; follow that addon's README and `godot --help` for your pinned version).
REM Until then this script FAILS ON PURPOSE, so nobody mistakes "no tests" for "all green".
setlocal
cd /d "%~dp0\.."
if "%GODOT%"=="" if exist "D:\godot\Godot_v4.7.2-stable_win64.exe" set GODOT=D:\godot\Godot_v4.7.2-stable_win64.exe

call tools\check_parse.bat
if errorlevel 1 exit /b 1

echo [run_tests] validating data
powershell -NoProfile -ExecutionPolicy Bypass -File tools\run_godot_bounded.ps1 -Godot "%GODOT%" -Arguments "--headless --path . --script tools/validate_data.gd" -OutputPath "%TEMP%\the_life_validate.log"
if errorlevel 1 (
  echo [run_tests] DATA VALIDATION FAILED
  exit /b 1
)

echo [run_tests] running GUT
powershell -NoProfile -ExecutionPolicy Bypass -File tools\run_godot_bounded.ps1 -Godot "%GODOT%" -Arguments "-s --path . addons/gut/gut_cmdln.gd -gdir=res://tests/unit -gprefix=test_ -gexit" -OutputPath "%TEMP%\the_life_gut.log"
set GUT_EXIT=%ERRORLEVEL%
if not "%GUT_EXIT%"=="0" (
  echo [run_tests] FAILED
  exit /b 1
)
findstr /C:"SCRIPT ERROR" /C:"Parse Error" /C:"Failed to load script" /C:"ERROR:" "%TEMP%\the_life_gut.log.stdout" "%TEMP%\the_life_gut.log.stderr" >nul
if not errorlevel 1 (
  echo [run_tests] ERROR TEXT FOUND
  exit /b 1
)
echo [run_tests] starting main scene headless
powershell -NoProfile -ExecutionPolicy Bypass -File tools\run_godot_bounded.ps1 -Godot "%GODOT%" -Arguments "--headless --path . --quit-after 120" -OutputPath "%TEMP%\the_life_main.log"
set MAIN_EXIT=%ERRORLEVEL%
if not "%MAIN_EXIT%"=="0" (
  echo [run_tests] MAIN SCENE FAILED
  exit /b 1
)
findstr /C:"SCRIPT ERROR" /C:"Parse Error" /C:"Failed to load script" /C:"ERROR:" "%TEMP%\the_life_main.log.stdout" "%TEMP%\the_life_main.log.stderr" >nul
if not errorlevel 1 (
  echo [run_tests] MAIN SCENE ERROR TEXT FOUND
  exit /b 1
)
echo [run_tests] PASS
endlocal
