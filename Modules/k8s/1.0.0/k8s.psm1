$PSDefaultParameterValues.Clear()
Set-StrictMode -Version Latest

Import-Module k8s.AzKeyVault
Import-Module k8s.SecretValueText
Import-Module k8s.Stats