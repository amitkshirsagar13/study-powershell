
class SecretValueItem {
    [SecureString] $SecretValue;
    [string] $SecretValueText
    SecretValueItem([string] $SecretValueText, [SecureString] $SecretValue) {
        $this.SecretValue = $SecretValue;
        $this.SecretValueText = $SecretValueText;
    }
    [string] GetSecretValueText() {
        $hashedString = ConvertFrom-SecureString -SecureString $this.SecretValue
        $unhashedString = ConvertTo-SecureString -String $hashedString
        $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($unhashedString)
        $this.SecretValueText = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
        return $this.SecretValueText;
    }

    [string] GetSecretValue() {
        $this.SecretValue = ConvertTo-SecureString $this.SecretValueText -asplaintext -force
        return $this.SecretValue;
    }
}

$PlainPassword = 'Pa$$W0rd'
$SecurePassword = ConvertTo-SecureString $PlainPassword -asplaintext -force
$secretItem = [SecretValueItem]::new($PlainPassword,$SecurePassword)
Write-Host $secretItem.GetSecretValueText()
Write-Host $secretItem.GetSecretValue()