@echo off
REM Runs: (1) parse check, (2) the unit-test framework headless.
REM Task 0.1 of the roadmap fills in step 2 with the REAL command for the framework you chose
REM (GUT or gdUnit4 - pick ONE; follow that addon's README and `godot --help` for your pinned version).
REM Until then this script FAILS ON PURPOSE, so nobody mistakes "no tests" for "all green".
setlocal
cd /d "%~dp0\.."

call tools\check_parse.bat
if errorlevel 1 exit /b 1

echo [run_tests] ^<^<FILL: put the exact headless test command for your test framework here^>^>
echo [run_tests] Test command is not configured yet (roadmap task 0.1).
exit /b 1
