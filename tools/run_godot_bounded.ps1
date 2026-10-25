param(
	[string]$Godot,
	[string]$Arguments,
	[string]$OutputPath,
	[int]$TimeoutMs = 120000
)

$stdoutPath = "$OutputPath.stdout"
$stderrPath = "$OutputPath.stderr"
$process = Start-Process -FilePath $Godot -ArgumentList $Arguments -RedirectStandardOutput $stdoutPath -RedirectStandardError $stderrPath -PassThru
if (-not $process.WaitForExit($TimeoutMs)) {
	Stop-Process -Id $process.Id
	Get-Content -LiteralPath $stdoutPath -Tail 60
	Get-Content -LiteralPath $stderrPath -Tail 60
	exit 124
}
Get-Content -LiteralPath $stdoutPath -Tail 60
Get-Content -LiteralPath $stderrPath -Tail 60
exit $process.ExitCode
