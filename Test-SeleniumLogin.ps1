using module .\Modules\k8s.Selenium\1.0.1\k8s.Selenium.psd1
Import-Module .\Modules\k8s.Selenium\1.0.1\k8s.Selenium.psd1

$BasePath=".\Selenium"
$EndPoint="https://github.com/login"
$IdToken="bundle-urls"
$AdminUser="amit.kshirsagar.13@gmail.com"
$AdminPass=Read-Host -Prompt 'Pass: '

$JToken = Test-SeleniumLogin -BasePath $BasePath -EndPoint $EndPoint -AdminUser $AdminUser -AdminPass $AdminPass -IdToken $IdToken

Write-Host $JToken