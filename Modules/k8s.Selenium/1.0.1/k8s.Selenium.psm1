#region Get-TestMessage
function Get-TestMessage {
  Write-Host "Hello Workflow!!!"
}
#endregion

#region Get-SEChrome
function Get-SEChrome {
  param(
    [Parameter(Mandatory)][string]$packagePath
  )
  Push-Location
  $path = Join-Path $packagePath ".\Selenium.WebDriver.*\lib\net40"
  $pathToWebDriver = Resolve-Path $path
  Write-Host "Load Webdriver!!!"
  Add-Type -Path (Join-Path $pathToWebDriver WebDriver.dll)
  Add-Type -Path (Join-Path $pathToWebDriver WebDriver.Support.dll)
  $path = Join-Path $packagePath ".\Selenium.WebDriver.ChromeDriver.*\driver\win32"
  $pathToChromeDriver = Resolve-Path $path

  $webdriver = New-Object OpenQA.Selenium.Chrome.ChromeDriver($pathToChromeDriver)
  return $webdriver;
}
#endregion

#region Test-SeleniumLogin
function Test-SeleniumLogin {
  param(
    [Parameter(Mandatory)][string]$BasePath,
    [Parameter(Mandatory)][string]$EndPoint,
    [Parameter(Mandatory)][string]$IdToken,
    [Parameter(Mandatory)][string]$AdminUser,
    [Parameter(Mandatory)][string]$AdminPass
  )
  $packages = "Packages"
  $packagePath = Join-Path $BasePath $packages

  [OpenQA.Selenium.Chrome.ChromeDriver]$ChromeDriver = Get-SEChrome -packagePath $packagePath  # Creates an instance of this class to control Selenium and stores it in an easy to handle variable
  $seleniumWait = New-Object -TypeName OpenQA.Selenium.Support.UI.WebDriverWait($ChromeDriver, (New-TimeSpan -Seconds 20))

  $ChromeDriver.Navigate().GoToURL($EndPoint)
  $seleniumWait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementIsVisible([OpenQA.Selenium.By]::Id("login_field")))
  $ChromeDriver.FindElementById("login_field").SendKeys($AdminUser)
  $ChromeDriver.FindElementById("password").SendKeys($AdminPass)
  $ChromeDriver.FindElementByXPath('//*[@id="login"]/form/div[4]/input[9]').Click()

  $seleniumWait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementIsVisible([OpenQA.Selenium.By]::XPath('//*[@id="dashboard-repos-filter-left"]')))
  $JToken = $ChromeDriver.ExecuteScript("return window.localStorage.getItem('$IdToken')")
  $ChromeDriver.Close()
  return $JToken
}
#endregion


#region Search-PinCode
function Test-RestCall {
  Param (
    [Parameter(Mandatory)][string]$EndPoint,
    [Parameter(Mandatory)][string]$Resource
  )
  $Uri = "$EndPoint/$Resource"
  $headers = @{
    'Resource' = "$Resource"
  }
  $Result = Invoke-RestMethod -Uri $Uri -Method Get -Headers $headers 
  $JsonResult = $Result | ConvertTo-Json
  Write-Host "Resource $Resource : $JsonResult"
  return $Result
}

#endregion
