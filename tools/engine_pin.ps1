# Shared by the bounded launcher; no engine is downloaded or selected here.
function Test-PinnedEngineVersion {
	param([string]$Version)
	return $Version.Trim() -cmatch '\A4\.7\.2\.stable(?:\.(?:mono\.)?official\.[0-9a-fA-F]+)?\z'
}

function Assert-PinnedGodotEngine {
	param([string]$Godot, [string]$OutputPrefix, [int]$TimeoutMs = 10000)
	$process = $null
	try {
		$process = Start-Process -WindowStyle Hidden -FilePath $Godot -ArgumentList '--version' -RedirectStandardOutput "$OutputPrefix.stdout" -RedirectStandardError "$OutputPrefix.stderr" -PassThru -ErrorAction Stop
		$null = $process.Handle
		if (-not $process.WaitForExit($TimeoutMs)) {
			Stop-Process -Id $process.Id -ErrorAction Stop
			$process.WaitForExit()
			throw 'Engine version probe timed out.'
		}
		$process.WaitForExit()
		if ($null -eq $process.ExitCode -or $process.ExitCode -ne 0) { throw 'Engine version probe failed.' }
		$version = [IO.File]::ReadAllText("$OutputPrefix.stdout").Trim()
		$errors = [IO.File]::ReadAllText("$OutputPrefix.stderr").Trim()
		if ($errors -or -not (Test-PinnedEngineVersion $version)) {
			throw "Expected Godot 4.7.2-stable; received '$version'."
		}
		return $version
	} finally {
		if ($null -ne $process) { $process.Dispose() }
	}
}
