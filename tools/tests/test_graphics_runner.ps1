$ErrorActionPreference = 'Stop'
$repo = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$runner = Join-Path $repo 'tools/run_graphics_tests.ps1'
$tokens = $null; $errors = $null
$ast = [Management.Automation.Language.Parser]::ParseFile($runner,[ref]$tokens,[ref]$errors)
if ($errors.Count) { throw $errors[0] }
# Load only the real function definitions, without an alternate production execution mode.
foreach ($definition in $ast.FindAll({ param($node) $node -is [Management.Automation.Language.FunctionDefinitionAst] },$false)) {
	. ([scriptblock]::Create($definition.Extent.Text))
}
$root = Join-Path $env:TEMP ('the_life_runner_probe_'+[Guid]::NewGuid().ToString('N'))
$null = New-Item -ItemType Directory -Path $root
$checks = 0
function Check([bool]$Condition,[string]$Message) { if (-not $Condition) { throw $Message }; $script:checks++ }
function Reject([scriptblock]$Action,[string]$Message) {
	$failed = $false
	try { $null = & $Action } catch { $failed = $true }
	Check $failed $Message
}
$inventory = @(Get-GraphicsInventory $repo)
$groups = Get-GraphicsGroups $inventory
Check ($groups.Count -eq 3) 'Not three groups'
$assigned = @($groups | ForEach-Object { $_.Path })
Assert-GraphicsCoverage @($inventory.Path) $assigned
$checks++
for ($index=0; $index -lt $inventory.Count; $index++) {
	Check ($groups[$index%3][[math]::Floor($index/3)].Path -ceq $inventory[$index].Path) 'Unstable partition'
}
Reject { Get-GraphicsGroups @($inventory[0],$inventory[1]) } 'Accepted empty group'
Reject { Assert-GraphicsCoverage @('a','b') @('a','a') } 'Accepted duplicate'
Reject { Assert-GraphicsCoverage @('a','b') @('a') } 'Accepted omission'
$out = Join-Path $root 'synthetic.stdout'; $err = Join-Path $root 'synthetic.stderr'
$good = "res://tests/unit/test_probe.gd`n= Run Summary`nScripts 1`nTests 2`nPassing Tests 2`nAsserts 8`nTime 0.25s`n---- All tests passed! ----`n"
[IO.File]::WriteAllText($out,$good); [IO.File]::WriteAllText($err,'')
$summary = Read-GraphicsSummary $out $err @('res://tests/unit/test_probe.gd') 2
Check ($summary.Tests -eq 2 -and $summary.Asserts -eq 8 -and $summary.Seconds -eq 0.25) 'Valid summary rejected'
foreach ($mutation in @(
	$good.Replace('= Run Summary','missing'), $good.Replace('Tests 2','Tests 3'),
	$good.Replace('Passing Tests 2','Passing Tests 1'), $good.Replace('Asserts 8','Asserts 0'),
	$good.Replace('Time 0.25s','Time bad'), $good.Replace('---- All tests passed! ----',''),
	($good+$good), ($good+"SCRIPT ERROR: broken`n"), ($good+"Failing Tests 1`n"),
	($good+"Pending 1`n"), ($good+"Risky/Pending 1`n"), ($good+"ObjectDB instances leaked`n"),
	$good.Replace('test_probe.gd','test_other.gd')
)) {
	[IO.File]::WriteAllText($out,$mutation)
	Reject { Read-GraphicsSummary $out $err @('res://tests/unit/test_probe.gd') 2 } 'Accepted malformed summary'
}
[IO.File]::WriteAllText($out,$good)
foreach ($message in @('Parse Error','ERROR:','Orphan Nodes 2','resources still in use')) {
	[IO.File]::WriteAllText($err,$message)
	Reject { Read-GraphicsSummary $out $err @('res://tests/unit/test_probe.gd') 2 } 'Accepted stderr error'
}
[IO.File]::WriteAllText($err,'')
Reject { Read-GraphicsSummary ($out+'.missing') $err @('res://tests/unit/test_probe.gd') 2 } 'Accepted absent log'
# Run a disposable replica to exercise orchestration/fail-fast/hash guards, never real tests/saves.
$sandbox = Join-Path $root 'replica'
$null = New-Item -ItemType Directory -Path "$sandbox/tools","$sandbox/tests/unit"
Copy-Item -LiteralPath $runner -Destination "$sandbox/tools/run_graphics_tests.ps1"
for ($index=0; $index -lt 7; $index++) { [IO.File]::WriteAllText("$sandbox/tests/unit/test_probe_$index.gd","func test_probe() -> void:`n`tpass`n") }
$fakeHelper = @'
param([string]$Godot,[string]$Arguments,[string]$OutputPath,[int]$TimeoutMs)
Add-Content -LiteralPath "$PSScriptRoot/calls.txt" -Value $TimeoutMs
$mode = [IO.File]::ReadAllText("$PSScriptRoot/mode.txt").Trim()
if ($mode -eq 'timeout') { exit 124 }
$paths = ($Arguments -split '-gtest=')[1].Split(' ')[0].Split(',')
$text = ($paths -join "`n")+"`n= Run Summary`nScripts $($paths.Count)`nTests $($paths.Count)`nPassing Tests $($paths.Count)`nAsserts $($paths.Count)`nTime 0.01s`n---- All tests passed! ----`n"
if ($mode -eq 'parse') { $text += "SCRIPT ERROR: probe`n" }
if ($mode -eq 'drift') { Add-Content -LiteralPath "$PSScriptRoot/../tests/unit/test_probe_0.gd" -Value '# drift' }
[IO.File]::WriteAllText("$OutputPath.stdout",$text)
[IO.File]::WriteAllText("$OutputPath.stderr",'')
exit 0
'@
[IO.File]::WriteAllText("$sandbox/tools/run_godot_bounded.ps1",$fakeHelper)
foreach ($mode in @('pass','timeout','parse','drift')) {
	[IO.File]::WriteAllText("$sandbox/tools/mode.txt",$mode)
	[IO.File]::WriteAllText("$sandbox/tools/calls.txt",'')
	$prefix = Join-Path $root $mode
	$child = Start-Process -WindowStyle Hidden -FilePath powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$sandbox/tools/run_graphics_tests.ps1`" -Godot probe -OutputPrefix `"$prefix`"" -RedirectStandardOutput "$prefix.launch.stdout" -RedirectStandardError "$prefix.launch.stderr" -PassThru
	$null = $child.Handle; $child.WaitForExit()
	Check (($child.ExitCode -eq 0) -eq ($mode -eq 'pass')) "Wrong result for $mode"
	$child.Dispose()
	$report = Get-Content -LiteralPath "$prefix.summary.json" -Raw | ConvertFrom-Json
	Check (($report.Status -eq 'passed') -eq ($mode -eq 'pass')) "Wrong report for $mode"
	$calls = @(Get-Content -LiteralPath "$sandbox/tools/calls.txt")
	Check ($calls.Count -eq $(if ($mode -in @('timeout','parse')) {1} else {3})) "Fail-fast failed for $mode"
	Check (@($calls | Where-Object { $_ -ne '180000' }).Count -eq 0) 'Timeout changed'
	if ($mode -eq 'pass') { Check ($report.Scripts -eq 7 -and $report.Tests -eq 7 -and $report.Groups.Count -eq 3) 'Aggregate incomplete' }
}
Write-Host "[graphics_runner_tests] PASS: $checks checks; $($inventory.Count) real scripts partitioned; evidence $root"
