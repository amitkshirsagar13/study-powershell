$PSVersionTable.PSVersion 

# Install-Module -Name Az -AllowClobber -Scope CurrentUser
# Connect-AzAccount
Get-AzResourceGroup  
$devTags = (Get-AzResourceGroup -Name "dev").Tags
Set-AzResourceGroup -Name "dev" -Tag $devTags
(Get-AzResourceGroup -Name "dev").Tags