#Connect to MsGraph
Connect-MgGraph -Scopes "User.Read.All","Group.ReadWrite.All"

# Export users with specific license to CSV file
$skuPartNumber = "STANDARDWOFFPACK_STUDENT"
$license = Get-MgSubscribedSku -All | Where-Object { $_.SkuPartNumber -eq $skuPartNumber }
if (-not $license) {
    Write-Host "License with SkuPartNumber '$skuPartNumber' not found."
    exit
}
$skuId = $license.SkuId
$users = Get-MgUser -All -Property Id, DisplayName, UserPrincipalName, JobTitle, AssignedLicenses `
         -Filter "assignedLicenses/any(x:x/skuId eq $skuId)"
$users | Select-Object Id, DisplayName, UserPrincipalName, JobTitle | Export-Csv -Path ".\Temp\UsersWithStudentLicense.csv" -NoTypeInformation -Encoding UTF8

# Remove MFA phone for users with specific license (إزالة هاتف التحقق من حسابات الطلاب)
$users = Import-Csv -Path ".\Temp\UsersWithStudentLicense.csv"
$i = 0
foreach ($user in $users) {
    $i++
    $authMethods = Get-MgUserAuthenticationMethod -UserId $user.UserPrincipalName
    $smsMethods = $authMethods | Where-Object { $_.PhoneType -eq "mobile" -and $_.PhoneNumber -ne $null }
    foreach ($smsMethod in $smsMethods) {
        Write-Host ("Removing SMS phone number for user: {0} ... ({1}/{2})" -f $user.UserPrincipalName, $i, $users.Count) -ForegroundColor Yellow
        Remove-MgUserAuthenticationPhoneMethod -UserId $user.UserPrincipalName -PhoneAuthenticationMethodId $smsMethod.Id
    }
}
