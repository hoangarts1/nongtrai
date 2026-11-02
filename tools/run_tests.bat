@echo off
REM Domain/2D regressions run headless; the COMPLETE GUT suite then uses the graphics renderer.
REM Archived-art tests await frame_post_draw and require the real renderer.
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

echo [run_tests] running domain and 2D headless tests
powershell -NoProfile -ExecutionPolicy Bypass -File tools\run_godot_bounded.ps1 -Godot "%GODOT%" -Arguments "--headless --path . --script addons/gut/gut_cmdln.gd -gtest=res://tests/unit/test_day_simulator.gd,res://tests/unit/test_farm_grid_state.gd,res://tests/unit/test_full_year_economy_simulation.gd,res://tests/unit/test_game_clock.gd,res://tests/unit/test_grid_math.gd,res://tests/unit/test_inventory_state.gd,res://tests/unit/test_merchant_service.gd,res://tests/unit/test_npc_data_validation.gd,res://tests/unit/test_npc_quest_delivery.gd,res://tests/unit/test_npc_schedule.gd,res://tests/unit/test_npc_social_save.gd,res://tests/unit/test_save_service.gd,res://tests/unit/test_wallet_state.gd,res://tests/unit/test_isometric_migration.gd,res://tests/unit/test_crop_inspector.gd,res://tests/unit/test_drag_farming.gd -gexit" -OutputPath "%TEMP%\the_life_headless.log"
if errorlevel 1 exit /b 1
powershell -NoProfile -Command "$text = (Get-Content -Raw '%TEMP%\the_life_headless.log.stdout') + (Get-Content -Raw '%TEMP%\the_life_headless.log.stderr'); if ($text -notmatch '---- All tests passed! ----' -or $text -match 'SCRIPT ERROR|Parse Error|Failed to load script|ERROR:|Failing Tests\s+[1-9][0-9]*') { exit 1 }"
if errorlevel 1 exit /b 1

echo [run_tests] running COMPLETE GUT suite with graphics renderer
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
powershell -NoProfile -Command "$text = (Get-Content -Raw '%TEMP%\the_life_gut.log.stdout') + (Get-Content -Raw '%TEMP%\the_life_gut.log.stderr'); if ($text -notmatch '---- All tests passed! ----' -or $text -match 'Failing Tests\s+[1-9][0-9]*') { exit 1 }"
if errorlevel 1 (
  echo [run_tests] TEST SUMMARY FAILED
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
