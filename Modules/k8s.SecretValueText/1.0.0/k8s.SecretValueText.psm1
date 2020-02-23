$PSDefaultParameterValues.Clear()
Set-StrictMode -Version Latest

function Get-SecretValueText 
{
  <#
  .SYNOPSIS
  Get Secret Text from SecureString value
  .DESCRIPTION
  Gets the Text Value of SecureString
  .PARAMETER SecretValue
  SecretValue value to be Converted to Text
  .EXAMPLE
  $PlainPassword = 'Pa$$W0rd'
  $SecurePassword = ConvertTo-SecureString $PlainPassword -asplaintext -force
  Get-SecretValueText -SecretValue $SecurePassword
  #>
  [cmdletbinding()]
  Param(
    [Parameter(ValueFromPipeline=$true,Mandatory=$true,Position=1)][SecureString] $SecretValue
  )
  $hashedString = ConvertFrom-SecureString -SecureString $SecretValue
  $unhashedString = ConvertTo-SecureString -String $hashedString
  $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($unhashedString)
  return [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
}