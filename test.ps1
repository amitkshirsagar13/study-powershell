$record=""
Write-Host "X-$record-X"
$Note = @("-",$record)[![string]::IsNullOrEmpty($record)]
Write-Host "X-$Note-X"

$record="OOOO"
Write-Host "X-$record-X"
$Note = @("-",$record)[![string]::IsNullOrEmpty($record)]
Write-Host "X-$Note-X"

Write-Debug "Debug"
Write-Information "Information"
Write-Warning "Warning"
Write-Log "Log"
