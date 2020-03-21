using module .\Modules\k8s.Selenium\1.0.1\k8s.Selenium.psd1
Import-Module .\Modules\k8s.Selenium\1.0.1\k8s.Selenium.psd1


$ConfigData = Get-Content -Raw -Path SeleniumConfig.json | ConvertFrom-Json

$BasePath=$ConfigData.BasePath
$EndPoint=$ConfigData.ClientEndpoint
$IdToken=$ConfigData.IdToken
$AdminUser=$ConfigData.AdminUser
$AdminPass=Read-Host -Prompt 'Pass: '

$JToken = Test-SeleniumLogin -BasePath $BasePath -EndPoint $EndPoint -AdminUser $AdminUser -AdminPass $AdminPass -IdToken $IdToken

Write-Host $JToken