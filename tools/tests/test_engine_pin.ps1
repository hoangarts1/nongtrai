param([string]$Godot = 'D:/godot/Godot_v4.7.2-stable_win64.exe')
$ErrorActionPreference = 'Stop'
. (Join-Path (Split-Path -Parent $PSScriptRoot) 'engine_pin.ps1')
$root = Join-Path $env:TEMP ('the_life_pin_probe_'+[Guid]::NewGuid().ToString('N'))
$null = New-Item -ItemType Directory -Path $root
$checks = 0
function Check([bool]$Condition, [string]$Message) {
	if (-not $Condition) { throw $Message }
	$script:checks++
}
foreach ($version in @('4.7.2.stable','4.7.2.stable.official.ed1daf0bf',"4.7.2.stable`r`n")) {
	Check (Test-PinnedEngineVersion $version) "Rejected $version"
}
foreach ($version in @('4.7.20.stable','4.7.2.dev','4.7.1.stable','4.8.stable','Godot 4.7.2.stable','',"4.7.2.stable`n4.7.2.stable",'4.7.2.stable.official.bad!')) {
	Check (-not (Test-PinnedEngineVersion $version)) "Accepted $version"
}
$actual = Assert-PinnedGodotEngine $Godot (Join-Path $root 'native')
Check ($actual -eq '4.7.2.stable.official.ed1daf0bf') 'Unexpected installed binary'
$fake = Join-Path $root 'fake.cmd'
foreach ($case in @(
	@('wrong','@echo 4.6.0.stable',10000),
	@('malformed','@echo garbage',10000),
	@('nonzero',"@echo 4.7.2.stable`r`n@exit /b 7",10000),
	@('stderr',"@echo 4.7.2.stable`r`n@echo warning 1>&2",10000),
	@('timeout','@ping -n 3 127.0.0.1 >nul',20)
)) {
	[IO.File]::WriteAllText($fake,"@echo off`r`n"+$case[1]+"`r`n")
	$rejected = $false
	try { $null = Assert-PinnedGodotEngine $fake (Join-Path $root $case[0]) $case[2] } catch { $rejected = $true }
	Check $rejected ('Accepted bad process '+$case[0])
}
$rejected = $false
try { $null = Assert-PinnedGodotEngine (Join-Path $root 'missing.exe') (Join-Path $root 'missing') } catch { $rejected = $true }
Check $rejected 'Accepted missing binary'
# A bad probe must prevent the requested target from running, including direct helper calls.
[IO.File]::WriteAllText($fake,"@echo off`r`nif `"%1`"==`"--version`" (echo 4.6.0.stable) else (echo reached>`"$root/target.txt`")`r`n")
$helper = Join-Path (Split-Path -Parent $PSScriptRoot) 'run_godot_bounded.ps1'
$blockedOutput = Join-Path $root 'blocked'
$child = Start-Process -WindowStyle Hidden -FilePath 'powershell' -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$helper`" -Godot `"$fake`" -Arguments --headless -OutputPath `"$blockedOutput`"" -RedirectStandardOutput "$blockedOutput.launch.stdout" -RedirectStandardError "$blockedOutput.launch.stderr" -PassThru
$null = $child.Handle
$child.WaitForExit()
Check ($child.ExitCode -ne 0) 'Helper accepted wrong engine'
$child.Dispose()
Check (-not (Test-Path -LiteralPath (Join-Path $root 'target.txt'))) 'Target ran after rejection'
Write-Host "[engine_pin_tests] PASS: $checks checks; evidence $root"
