# Invoke-RestMethod -Uri https://reqres.in/api/users/2
Write-Host "----------------------------------------------------------"

$restResponse = $(Invoke-RestMethod -Uri https://reqres.in/api/users/2)
$jsonResponse = $restResponse.data|ConvertTo-Json
Write-Host $jsonResponse
$response = $jsonResponse|ConvertFrom-Json

Write-Host $response.id