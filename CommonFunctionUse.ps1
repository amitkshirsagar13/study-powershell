<#
.Description
  Working with basic commands.
#>

$someString = $( Read-Host "Provide Some string: " -AsSecureString)
Write-Host "Input String: $someString "

$hashedString = ConvertFrom-SecureString -SecureString $someString
Write-Host "Hashed String: $hashedString "

$unhashedString = ConvertTo-SecureString -String $hashedString
Write-Host "UnHashed String: $unhashedString "
$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($unhashedString)
$UnsecurePassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)


Write-Host "Decoded Input: $UnsecurePassword "

Write-Host "====================================================="
$PlainPassword = "JustPlainText"
$SecurePassword = ConvertTo-SecureString $PlainPassword -asplaintext -force
$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecurePassword)
$UnsecurePassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

Write-Host "Reversed Password: $UnsecurePassword "