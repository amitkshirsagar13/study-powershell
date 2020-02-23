
function Get-SecretValueText 
{
  <#
  .DESCRIPTION
  Gets the Text Value of SecureString
  .PARAMETER SecretValue
  SecretValue value to be Converted to Text
  .EXAMPLE
  $PlainPassword = 'Pa$$W0rd'
  $SecurePassword = ConvertTo-SecureString $PlainPassword -asplaintext -force
  Get-SecretTextValue -SecretValue $SecurePassword
  #>
  Param(
    [Parameter(ValueFromPipeline=$true,Mandatory=$true,Position=1)][SecureString] $SecretValue
  )
  $hashedString = ConvertFrom-SecureString -SecureString $SecretValue
  $unhashedString = ConvertTo-SecureString -String $hashedString
  $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($unhashedString)
  return [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
}

function Copy-PfxCerts {
Param ([string] $srcSubId = "368eb6b3-4e02-4d22-a05d-767dc9dc4819",
        [string] $destSubId = "368eb6b3-4e02-4d22-a05d-767dc9dc4819",
        [string] $srcVaultName = $(throw "Required -srcVaultName"),
        [string] $destVaultName = $(throw "Required -destVaultName"),
        [string] $certName = $(throw "Required -certName"),
        [SecureString] $SecurePassword = $(throw "Required -SecurePassword")
)
  Write-host "Copy starting $certName"
  Select-AzSubscription -Subscription $srcSubId
  # $cert = $(Get-AzKeyVaultCertificate -VaultName $srcVaultName -Name $certName)
  $secret = $(Get-AzKeyVaultSecret -VaultName $srcVaultName -Name $certName)
  Write-Host $secret.SecretValueText
  $secretByte = [Convert]::FromBase64String($secret.SecretValueText)
  [System.IO.File]::WriteAllBytes("tmpKeyVaultCertByte.blob", $secretByte)

  $x509Cert = New-Object -TypeName System.Security.Cryptography.X509Certificates.X509Certificate2("tmpKeyVaultCertByte.blob");
  $type = [System.Security.Cryptography.X509Certificates.X509ContentType]::Pfx
  $pfxFileByte = $x509Cert.Export($type, $password)
  # # Write to a file
  [System.IO.File]::WriteAllBytes("tmpKeyVaultCert.pfx", $pfxFileByte)
  $password = SecretValueText -SecurePassword $SecurePassword

  # # Upload to KeyVault
  Select-AzSubscription -Subscription $destSubId
  Import-AzKeyVaultCertificate -VaultName $destVaultName -Name $certName -Password $SecurePassword -FilePath "tmpKeyVaultCert.pfx"
  Write-host "Copy finished: $certName"
}

function Copy-PemCerts {
  Param ([string] $srcSubId = "368eb6b3-4e02-4d22-a05d-767dc9dc4819",
          [string] $destSubId = "368eb6b3-4e02-4d22-a05d-767dc9dc4819",
          [string] $srcVaultName = $(throw "Required -srcVaultName"),
          [string] $destVaultName = $(throw "Required -destVaultName"),
          [string] $certName = $(throw "Required -certName"),
          [SecureString] $SecurePassword = $(throw "Required -SecurePassword")
  )
    Write-host "Copy starting $certName"
    Select-AzSubscription -Subscription $srcSubId
    # $cert = $(Get-AzKeyVaultCertificate -VaultName $srcVaultName -Name $certName)
    $secret = $(Get-AzKeyVaultSecret -VaultName $srcVaultName -Name $certName)
    Write-Host $secret.SecretValueText

    [System.IO.File]::WriteAllLines("tmpKeyVaultCert.pem", $secret.SecretValueText)

    $regex='-----BEGIN CERTIFICATE-----'
    $fileName='cert.key'
    foreach($line in [System.IO.File]::ReadLines("tmpKeyVaultCert.pem")) {
        if($line -match $regex){
            $fileName='cert.crt'
        }
        Add-Content -Path $fileName -Value $line
    }

  openssl pkcs12 -export -in cert.crt -inkey cert.key -passin pass:$password -out tmpKeyVaultCertFromPem.pfx -passout pass:$password

  $password = Get-SecretValueText -SecurePassword $SecurePassword

  # # Upload to KeyVault
  Select-AzSubscription -Subscription $destSubId
  Import-AzKeyVaultCertificate -VaultName $destVaultName -Name $certName -Password $SecurePassword -FilePath "tmpKeyVaultCertFromPem.pfx"
  Write-host "Copy finished: $certName"
}
 
$srcSubId = "368eb6b3-4e02-4d22-a05d-767dc9dc4819"
$destSubId = "368eb6b3-4e02-4d22-a05d-767dc9dc4819"

$PlainPassword = 'Pa$$W0rd'
$SecurePassword = ConvertTo-SecureString $PlainPassword -asplaintext -force
$password = Get-SecretValueText -SecurePassword $SecurePassword

Get-ChildItem * -Include "cert*","tmpK*"|Remove-Item
Copy-PfxCerts -srcVaultName 'devVault-src' -destVaultName 'devVault-dest' -certName 'test-cert-pfx' -SecurePassword $SecurePassword
Copy-PemCerts -srcVaultName 'devVault-src' -destVaultName 'devVault-dest' -certName 'test-cert-pem' -SecurePassword $SecurePassword
Get-ChildItem * -Include "cert*","tmpK*"|Remove-Item