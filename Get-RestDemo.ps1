using module .\Modules\k8s.Selenium\1.0.1\k8s.Selenium.psd1
Import-Module .\Modules\k8s.Selenium\1.0.1\k8s.Selenium.psd1

$EndPoint="http://dummy.restapiexample.com/api/v1"
$Resource="employees"
$result = Test-RestCall -EndPoint $EndPoint -Resource $Resource
$jsonResponse = $result.data|ConvertTo-Json
Write-Host $jsonResponse