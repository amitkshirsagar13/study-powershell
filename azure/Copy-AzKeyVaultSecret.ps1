function CopySecrets {
Param ([string] $devSubId = "3feb035d-e016-49a7-9b2b-374e08e94ed8",
        [string] $stageSubId = "46f0852a-16c5-4894-a57c-b90976e4c72a",
        [string] $devVaultName = $(throw "Required -devVaultName"),
        [string] $stgVaultName = $(throw "Required -stgVaultName"),
        [string] $secretName = $(throw "Required -secretName")
)
  Write-host "Copy starting $secretName"
  #Login-AzAccount 
  Select-AzSubscription -Subscription $devSubId
  $secretValue = $(Get-AzKeyVaultSecret -VaultName $devVaultName -Name $secretName).SecretValueText
  Select-AzSubscription -Subscription $stageSubId
  Set-AzKeyVaultSecret -VaultName $stgVaultName -Name $secretName  -SecretValue $secretValue
  Write-host "Copy finished: $secretName"
}

$devSubId = "3feb035d-e016-49a7-9b2b-374e08e94ed8"
$stageSubId = "46f0852a-16c5-4894-a57c-b90976e4c72a"

CopySecrets -devVaultName 'devVault' -stgVaultName 'stgVaultName' -secretName 'secretName'