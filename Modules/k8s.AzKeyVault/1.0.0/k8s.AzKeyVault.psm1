function Copy-AzKeyVaultPfxCerts 
{
    <#
    .SYNOPSIS
    Copy Pfx Cert within AzAccount
    .DESCRIPTION
    Copy the Pfx Cert from srcKeyVault to destKeyVault in Same or different Subscriptions
    .PARAMETER srcSubId
    Source Subscription Id
    .PARAMETER destSubId
    Destination Subscription Id
    .PARAMETER srcVaultName
    Source KeyVault Name
    .PARAMETER destVaultName
    Destination KeyVault Name
    .PARAMETER certName
    Certificate Name to be copied
    .PARAMETER password
    Password involved with Certificate
    .EXAMPLE
    $PlainPassword = 'Pa$$W0rd'
    $SecurePassword = ConvertTo-SecureString $PlainPassword -asplaintext -force
    Copy-PfxCerts -srcSubId "$subId" -descSubId "$subId" -srcVaultName 'devVault-src' -destVaultName 'devVault-dest' -certName 'test-cert-pfx' -SecurePassword $SecurePassword
    #>
    [cmdletbinding()]
    Param ([string] $srcSubId = $(throw "Required -srcSubId"),
            [string] $destSubId = $(throw "Required -destSubId"),
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
    
function Copy-AzKeyVaultPemCerts 
{
    <#
    .SYNOPSIS
    Copy Pem Cert within AzAccount
    .DESCRIPTION
    Copy the Pem Cert from srcKeyVault to destKeyVault in Same or different Subscriptions
    .PARAMETER srcSubId
    Source Subscription Id
    .PARAMETER destSubId
    Destination Subscription Id
    .PARAMETER srcVaultName
    Source KeyVault Name
    .PARAMETER destVaultName
    Destination KeyVault Name
    .PARAMETER certName
    Certificate Name to be copied
    .PARAMETER password
    Password involved with Certificate
    .EXAMPLE
    $PlainPassword = 'Pa$$W0rd'
    $SecurePassword = ConvertTo-SecureString $PlainPassword -asplaintext -force
    Copy-PemCerts -srcSubId "$subId" -descSubId "$subId" -srcVaultName 'devVault-src' -destVaultName 'devVault-dest' -certName 'test-cert-pem' -SecurePassword $SecurePassword
    #>
    [cmdletbinding()]
    Param ([string] $srcSubId = $(throw "Required -srcSubId"),
            [string] $destSubId = $(throw "Required -destSubId"),
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
     