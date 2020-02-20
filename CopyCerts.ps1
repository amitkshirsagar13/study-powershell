function CopyCerts {
Param ([string] $devSubId = "368eb6b3-4e02-4d22-a05d-767dc9dc4819",
        [string] $stageSubId = "368eb6b3-4e02-4d22-a05d-767dc9dc4819",
        [string] $devVaultName = $(throw "Required -devVaultName"),
        [string] $stgVaultName = $(throw "Required -stgVaultName"),
        [string] $certName = $(throw "Required -certName"),
        [string] $password = $(throw "Required -password")
)
  Write-host "Copy starting $certName"
  Select-AzSubscription -Subscription $devSubId
  $cert = $(Get-AzKeyVaultCertificate -VaultName $devVaultName -Name $certName)
  $secret = $(Get-AzKeyVaultSecret -VaultName $devVaultName -Name $certName)
  Write-Host $secret.SecretValueText
  $secretByte = [Convert]::FromBase64String($secret.SecretValueText)
  $x509Cert = new-object System.Security.Cryptography.X509Certificates.X509Certificate2
  $x509Cert.Import($secretByte, "", "Exportable,PersistKeySet")
  $type = [System.Security.Cryptography.X509Certificates.X509ContentType]::Pfx
  $pfxFileByte = $x509Cert.Export($type, $password)
  # # Write to a file
  [System.IO.File]::WriteAllBytes("./tmpKeyValtCert.pfx", $pfxFileByte)
  $SecurePassword = ConvertTo-SecureString $password -asplaintext -force

  # # Upload to KeyVault
  Select-AzSubscription -Subscription $stageSubId
  Import-AzKeyVaultCertificate -VaultName $stgVaultName -Name $certName -Password $SecurePassword -FilePath "./tmpKeyValtCert.pfx"
  Write-host "Copy finished: $certName"
}

$devSubId = "368eb6b3-4e02-4d22-a05d-767dc9dc4819"
$stageSubId = "368eb6b3-4e02-4d22-a05d-767dc9dc4819"

CopyCerts -devVaultName 'devVault-src' -stgVaultName 'devVault-dest' -certName 'test-cert' -password '1234'