param(
	[Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$Godot,
	[ValidateNotNullOrEmpty()][string]$OutputPrefix = (Join-Path $env:TEMP 'the_life_gut')
)

$ErrorActionPreference = 'Stop'

function Get-GraphicsInventory([string]$RepoRoot) {
	[string[]]$names = @(Get-ChildItem -LiteralPath (Join-Path $RepoRoot 'tests/unit') -Filter 'test_*.gd' -File | ForEach-Object { $_.Name })
	[Array]::Sort($names, [StringComparer]::Ordinal)
	if ($names.Count -lt 3) { throw 'Graphics discovery requires at least three test scripts.' }
	foreach ($name in $names) {
		if ($name -cnotmatch '^test_[a-z0-9_]+\.gd$') { throw "Unsupported test filename: $name" }
		$path = Join-Path $RepoRoot "tests/unit/$name"
		$count = [regex]::Matches([IO.File]::ReadAllText($path), '(?m)^func test_[A-Za-z0-9_]+\s*\(').Count
		if ($count -eq 0) { throw "No top-level tests discovered in $name; review the runner contract." }
		[PSCustomObject]@{ Path = "res://tests/unit/$name"; Tests = $count; Hash = (Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash }
	}
}

function Assert-GraphicsCoverage([string[]]$Expected, [string[]]$Actual) {
	if ($Expected.Count -eq 0 -or $Actual.Count -ne $Expected.Count) { throw 'Graphics script coverage count mismatch.' }
	[string[]]$left = @($Expected)
	[string[]]$right = @($Actual)
	[Array]::Sort($left, [StringComparer]::Ordinal)
	[Array]::Sort($right, [StringComparer]::Ordinal)
	for ($index = 0; $index -lt $left.Count; $index++) {
		if ($index -gt 0 -and ($left[$index] -ceq $left[$index-1] -or $right[$index] -ceq $right[$index-1])) { throw 'Duplicate graphics script coverage.' }
		if ($left[$index] -cne $right[$index]) { throw "Graphics script coverage mismatch: $($right[$index])" }
	}
}

function Get-GraphicsGroups([object[]]$Inventory) {
	if ($Inventory.Count -lt 3) { throw 'Three graphics groups require at least three scripts.' }
	$groups = @(@(), @(), @())
	for ($index = 0; $index -lt $Inventory.Count; $index++) { $groups[$index % 3] += $Inventory[$index] }
	return ,$groups
}

function Read-GraphicsSummary([string]$StdoutPath, [string]$StderrPath, [string[]]$ExpectedPaths, [int]$ExpectedTests) {
	if (-not (Test-Path -LiteralPath $StdoutPath -PathType Leaf) -or -not (Test-Path -LiteralPath $StderrPath -PathType Leaf)) { throw 'Missing graphics stdout/stderr log.' }
	$out = [regex]::Replace([IO.File]::ReadAllText($StdoutPath), '\x1b\[[0-9;]*m', '')
	$err = [regex]::Replace([IO.File]::ReadAllText($StderrPath), '\x1b\[[0-9;]*m', '')
	$errorPattern = 'SCRIPT ERROR|Parse Error|Failed to load script|ERROR:|ObjectDB instances leaked|resources still in use|(?:Failing Tests|Risky/Pending|Risky Tests|Pending|Errors|Orphan Nodes|Orphans)\s+[1-9][0-9]*|[1-9][0-9]* [Oo]rphans'
	if ([regex]::IsMatch($out+"`n"+$err, $errorPattern)) { throw 'Graphics output contains an error, failure, pending test or leak.' }
	$headers = @([regex]::Matches($out, '(?m)^= Run Summary\s*$'))
	$success = @([regex]::Matches($out, '(?m)^---- All tests passed! ----\s*$'))
	if ($headers.Count -ne 1 -or $success.Count -ne 1 -or $success[0].Index -lt $headers[0].Index) { throw 'Missing or duplicate complete graphics success summary.' }
	$summary = $out.Substring($headers[0].Index)
	$values = @{}
	foreach ($field in @('Scripts','Tests','Passing Tests','Asserts')) {
		$matches = @([regex]::Matches($summary, '(?m)^'+[regex]::Escape($field)+'\s+([0-9]+)\s*$'))
		if ($matches.Count -ne 1) { throw "Invalid graphics summary field: $field" }
		$values[$field] = [int]$matches[0].Groups[1].Value
	}
	$times = @([regex]::Matches($summary, '(?m)^Time\s+([0-9]+(?:\.[0-9]+)?)s\s*$'))
	if ($times.Count -ne 1) { throw 'Invalid graphics summary time.' }
	if ($values.Scripts -ne $ExpectedPaths.Count -or $ExpectedTests -le 0 -or $values.Tests -ne $ExpectedTests -or $values.Tests -ne $values['Passing Tests'] -or $values.Asserts -le 0) { throw 'Graphics summary does not cover all discovered tests.' }
	[string[]]$actual = @([regex]::Matches($out, '(?m)^res://[^\r\n]+\.gd\r?$') | ForEach-Object { $_.Value.TrimEnd("`r") })
	Assert-GraphicsCoverage $ExpectedPaths $actual
	[PSCustomObject]@{ Scripts = $values.Scripts; Tests = $values.Tests; Passing = $values['Passing Tests']; Asserts = $values.Asserts; Seconds = [double]::Parse($times[0].Groups[1].Value, [Globalization.CultureInfo]::InvariantCulture) }
}

try {
	$repoRoot = Split-Path -Parent $PSScriptRoot
	Set-Location -LiteralPath $repoRoot
	$inventory = @(Get-GraphicsInventory $repoRoot)
	$groups = Get-GraphicsGroups $inventory
	Assert-GraphicsCoverage @($inventory.Path) @($groups | ForEach-Object { $_.Path })
	$parent = Split-Path -Parent ([IO.Path]::GetFullPath($OutputPrefix))
	$null = New-Item -ItemType Directory -Force -Path $parent
	@{ Status = 'running' } | ConvertTo-Json | Set-Content -LiteralPath "$OutputPrefix.summary.json" -Encoding UTF8
	@{ TimeoutMsPerProcess = 180000; Inventory = $inventory; Groups = $groups } | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath "$OutputPrefix.manifest.json" -Encoding UTF8
	$watch = [Diagnostics.Stopwatch]::StartNew()
	$results = @()
	for ($index = 0; $index -lt $groups.Count; $index++) {
		$number = $index+1
		$paths = @($groups[$index].Path)
		$expectedTests = ($groups[$index] | Measure-Object -Property Tests -Sum).Sum
		$logPath = "${OutputPrefix}_${number}.log"
		Write-Host "[graphics_tests] group $number/$($groups.Count): $($paths.Count) scripts, $expectedTests tests; timeout 180s"
		$arguments = '-s --path . addons/gut/gut_cmdln.gd -gtest='+($paths -join ',')+' -gexit'
		& powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $PSScriptRoot 'run_godot_bounded.ps1') -Godot $Godot -Arguments $arguments -OutputPath $logPath -TimeoutMs 180000
		if ($LASTEXITCODE -ne 0) { throw "Graphics group $number exited $LASTEXITCODE (124 means timeout)." }
		$results += Read-GraphicsSummary "$logPath.stdout" "$logPath.stderr" $paths $expectedTests
	}
	$after = @(Get-GraphicsInventory $repoRoot)
	Assert-GraphicsCoverage @($inventory.Path) @($after.Path)
	for ($index = 0; $index -lt $inventory.Count; $index++) {
		if ($inventory[$index].Hash -cne $after[$index].Hash) { throw "Test source changed during execution: $($inventory[$index].Path)" }
	}
	$watch.Stop()
	$total = [ordered]@{ Status = 'passed'; Scripts = ($results | Measure-Object Scripts -Sum).Sum; Tests = ($results | Measure-Object Tests -Sum).Sum; Passing = ($results | Measure-Object Passing -Sum).Sum; Asserts = ($results | Measure-Object Asserts -Sum).Sum; GutSeconds = ($results | Measure-Object Seconds -Sum).Sum; WallSeconds = $watch.Elapsed.TotalSeconds; Groups = $results }
	$total | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath "$OutputPrefix.summary.json" -Encoding UTF8
	Write-Host "[graphics_tests] PASS: $($total.Scripts) scripts, $($total.Passing)/$($total.Tests) tests, $($total.Asserts) assertions; GUT $($total.GutSeconds)s, wall $($total.WallSeconds)s"
	exit 0
} catch {
	if (Test-Path -LiteralPath "$OutputPrefix.summary.json" -PathType Leaf) {
		@{ Status = 'failed'; Error = $_.Exception.Message } | ConvertTo-Json | Set-Content -LiteralPath "$OutputPrefix.summary.json" -Encoding UTF8
	}
	[Console]::Error.WriteLine('[graphics_tests] FAILED: '+$_.Exception.Message)
	exit 1
}
