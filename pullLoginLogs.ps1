$ErrorActionPreference = "Stop"

$AccountName = "username"
$Password = Get-Content ".\mfaGReaderCert.txt" | ConvertTo-SecureString
$Credential = New-Object System.Management.Automation.PSCredential($AccountName, $Password)
Connect-AzureAD -Credential $Credential
