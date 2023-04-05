Connect-MsolService
$Users = Get-MsolUser -All | ? { $_.UserType -ne  "Guest" }
# Output file
$Report = [System.Collections.Generic.List[Object]]::new()
Write-Host "Processing" $Users.Count "accounts..."
ForEach ($User in $Users) {
    $MFAEnforced = $User.StrongAuthenticationRequirements.State
    $MFAPhone = $User.StrongAuthenticationUserDetails.PhoneNumber
    $DefaultMFAMethod = ($User.StrongAuthenticationMethods | ? { $_.IsDefault -eq "True" }).MethodType
    If (($MFAEnforced -eq "Enforced") -or ($MFAEnforced -eq "Enabled")) {
        Switch ($DefaultMFAMethod) {
            "OneWaySMS" { $MethodUsed = "One-way SMS" }
            "TwoWayVoiceMobile" { $MethodUsed = "Phone call verification" }
            "PhoneAppOTP" { $MethodUsed = "Hardware token or authenticator app" }
            "PhoneAppNotification" { $MethodUsed = "Authenticator app" }
        }
    }
    Else {
        $MFAEnforced = "Not Enabled"
        $MethodUsed = "MFA Not Used"
    }
     
    $ReportLine = [PSCustomObject] @{
        User        = $User.UserPrincipalName
        Name        = $User.DisplayName
        Department  = $User.Department
        JobTitle    = $User.JobTitle
        MFAUsed     = $MFAEnforced
        MFAMethod   = $MethodUsed
        PhoneNumber = $MFAPhone
    }
     
        $Report.Add($ReportLine)
}
     
Write-Host "Report is in (path)"
$Report | Select-Object User, Name, Department, JobTitle, MFAUsed, MFAMethod, PhoneNumber | Sort Name | Out-GridView
$Report | Sort Name | Export-CSV -NoTypeInformation -Encoding UTF8 #path
