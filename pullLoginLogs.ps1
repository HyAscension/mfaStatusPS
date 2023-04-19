$ErrorActionPreference = "Stop"

$AccountName = "username"
$Password = Get-Content ".\mfaGReaderCert.txt" | ConvertTo-SecureString
$Credential = New-Object System.Management.Automation.PSCredential($AccountName, $Password)
Connect-AzureAD -Credential $Credential

$range = 0
$startTime = (Get-Date).AddHours(-3).ToUniversalTime()
$endTime = (Get-Date).ToUniversalTime()

$Report = [System.Collections.Generic.List[Object]]::new()

# Loop 3 times per day time 7 for a week
while ($range -lt 168) {
    
    # Get audit logs of sign ins. Filter between today and 7 days ago
    $halfDayReport = Get-AzureADAuditSignInLogs -Filter "createdDateTime gt $($startTime.ToString("yyyy-MM-ddTHH:mm:ss.ffK")) and createdDateTime lt $($endTime.ToString("yyyy-MM-ddTHH:mm:ss.ffK"))"

    Write-Host "Processing" $halfDayReport.Count "logs..."

    # Save data to variables
    foreach ($object in $halfDayReport) {

        $location = "$($object.Location.City), $($object.Location.State), $($object.Location.CountryOrRegion)"

        $status = ""
        if ($object.Status.ErrorCode -eq 0) {
            $status = "Success"
        } elseif ($object.Status.ErrorCode -eq 50097) {
            $status = "Pending"
        } else {
            $status = "Failure"
        }

        $authType = ""
        if ($null -eq $object.MfaDetail) {
            $authType = "Single-factor authentication"
        } else {
            $authType = "Multifactor authentication"
        }

        # Save data to object
        $ReportLine = [PSCustomObject] @{
                Date            = $object.CreatedDateTime
                RequestID       = $object.Id
                FullName        = $object.UserDisplayName
                User            = $object.UserPrincipalName
                Application     = $object.AppDisplayName
                IpAddress       = $object.IpAddress
                Location        = $location
                Status          = $status
                Browser         = $object.DeviceDetail.Browser
                OperatingSystem = $object.DeviceDetail.OperatingSystem
                Authentication  = $authType
                Policies        = "notApplied"
        }

        # Save object to generic list
        $Report.Add($ReportLine)
    }

    
    #$output += $halfDayReport
    if ($range -lt 2) {
        Write-Host "Extracted $(($range + 1) / 8) day worth of logs"
    } else {
        Write-Host "Extracted $(($range + 1) / 8) days worth of logs"
    }
    $startTime = $startTime.AddHours(-3)
    $endTime = $endTime.AddHours(-3)
    $range += 1
}


$Report | Select-Object Date, RequestID, FullName, User, Application, IpAddress, Location, Status, Browser, OperatingSystem, Authentication, Policies | Sort Date | Out-GridView

$Report | Export-Csv -Path # Path\InteractiveSignIns.csv

python # Path\remove_first_row.py