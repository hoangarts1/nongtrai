param(
	[string]$Godot,
	[string]$Arguments,
	[string]$OutputPath,
	[int]$TimeoutMs = 120000
)

$stdoutPath = "$OutputPath.stdout"
$stderrPath = "$OutputPath.stderr"
$originalAppData = $env:APPDATA
try {
	# Every invocation uses an isolated user:// so test saves/settings cannot alter the player's.
	$env:APPDATA = Join-Path $env:TEMP 'the_life_test_appdata'
	$process = Start-Process -WindowStyle Hidden -FilePath $Godot -ArgumentList $Arguments -RedirectStandardOutput $stdoutPath -RedirectStandardError $stderrPath -PassThru
	# Retain the native handle before waiting; otherwise Windows PowerShell can lose ExitCode.
	$null = $process.Handle
	if (-not $process.WaitForExit($TimeoutMs)) {
		Stop-Process -Id $process.Id
		Get-Content -LiteralPath $stdoutPath -Tail 60
		Get-Content -LiteralPath $stderrPath -Tail 60
		exit 124
	}
	$process.WaitForExit()
	$exitCode = $process.ExitCode
	Get-Content -LiteralPath $stdoutPath -Tail 60
	Get-Content -LiteralPath $stderrPath -Tail 60
	if ($null -eq $exitCode) {
		Write-Error 'Godot process did not return an exit code.'
		exit 1
	}
	exit $exitCode
} finally {
	$env:APPDATA = $originalAppData
}
