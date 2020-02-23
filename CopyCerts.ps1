
function TextPassword {
  Param(
    [SecureString] $SecurePassword = $(throw "Required -SecurePassword")
  )
  $hashedString = ConvertFrom-SecureString -SecureString $SecurePassword
  $unhashedString = ConvertTo-SecureString -String $hashedString
  $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($unhashedString)
  return [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
}
 
function CopyPfxCerts {
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
  [System.IO.File]::WriteAllBytes("tmpKeyVaultCertByte.pfx", $secretByte)

  $x509Cert = New-Object -TypeName System.Security.Cryptography.X509Certificates.X509Certificate2("tmpKeyVaultCertByte.pfx");
  $type = [System.Security.Cryptography.X509Certificates.X509ContentType]::Pfx
  $pfxFileByte = $x509Cert.Export($type, $password)
  # # Write to a file
  [System.IO.File]::WriteAllBytes("tmpKeyVaultCert.pfx", $pfxFileByte)
  $password = TextPassword -SecurePassword $SecurePassword

  # # Upload to KeyVault
  Select-AzSubscription -Subscription $destSubId
  Import-AzKeyVaultCertificate -VaultName $destVaultName -Name $certName -Password $SecurePassword -FilePath "tmpKeyVaultCert.pfx"
  Write-host "Copy finished: $certName"
}

function CopyPemCerts {
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

    Remove-Item cert*
    $regex='-----BEGIN CERTIFICATE-----'
    $fileName='cert.key'
    foreach($line in [System.IO.File]::ReadLines("tmpKeyVaultCert.pem")) {
        if($line -match $regex){
            $fileName='cert.crt'
        }
        Add-Content -Path $fileName -Value $line
    }

    openssl pkcs12 -export -in cert.crt -inkey cert.key -passin pass:$password -out tmpKeyVaultCertFromPem.pfx -passout pass:$password

    $password = TextPassword -SecurePassword $SecurePassword
  
    # # Upload to KeyVault
    Select-AzSubscription -Subscription $destSubId
    Import-AzKeyVaultCertificate -VaultName $destVaultName -Name $certName -Password $SecurePassword -FilePath "tmpKeyVaultCertFromPem.pfx"
    Write-host "Copy finished: $certName"
  }
 
$srcSubId = "368eb6b3-4e02-4d22-a05d-767dc9dc4819"
$destSubId = "368eb6b3-4e02-4d22-a05d-767dc9dc4819"

$PlainPassword = 'Pa$$W0rd'
$SecurePassword = ConvertTo-SecureString $PlainPassword -asplaintext -force
$password = TextPassword -SecurePassword $SecurePassword
# Write-Host $password
CopyPfxCerts -srcVaultName 'devVault-src' -destVaultName 'devVault-dest' -certName 'test-cert' -SecurePassword $SecurePassword
CopyPemCerts -srcVaultName 'devVault-src' -destVaultName 'devVault-dest' -certName 'test-cert-pem' -SecurePassword $SecurePassword

Remove-Item cert* tmpK*