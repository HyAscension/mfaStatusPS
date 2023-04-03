Connect-MsolService
$Users = Get-MsolUser -All | ? { $_.UserType -ne  "Guest" }
# Output file
$Report = [System.Collections.Generic.List[Object]]::new()
Write-Host "Processing" $Users.Count "accounts..."
