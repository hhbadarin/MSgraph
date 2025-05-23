#Connect to MsGraph
Connect-MgGraph -Scopes "User.Read.All","Group.ReadWrite.All"

# Remove MFA phone for users with specific license (إزالة هاتف التحقق من حسابات الطلاب)
$skuPartNumber = "STANDARDWOFFPACK_STUDENT"
$license = Get-MgSubscribedSku -All | Where-Object { $_.SkuPartNumber -eq $skuPartNumber }
if (-not $license) {
    Write-Host "License with SkuPartNumber '$skuPartNumber' not found."
    exit
}
$skuId = $license.SkuId
$users = Get-MgUser -All -Property Id, DisplayName, UserPrincipalName, JobTitle, AssignedLicenses `
         -Filter "assignedLicenses/any(x:x/skuId eq $skuId)"
$totalUsers = $users.Count
$counter = 0
foreach ($user in $users) {
    $counter++
    $progress = [math]::Round(($counter / $totalUsers) * 100, 2)
    Write-Progress -Activity "Processing Users" -Status "Progress: $progress% ($counter of $totalUsers)" -PercentComplete $progress
    $authMethods = Get-MgUserAuthenticationMethod -UserId $user.UserPrincipalName
    $smsMethods = $authMethods | Where-Object { $_.PhoneType -eq "mobile" -and $_.PhoneNumber -ne $null }
    foreach ($smsMethod in $smsMethods) {
        Write-Host "Removing SMS phone number for user: $($user.UserPrincipalName)"
        Remove-MgUserAuthenticationPhoneMethod -UserId $user.UserPrincipalName -PhoneAuthenticationMethodId $smsMethod.Id
    }
}
Write-Host "Processing complete. $counter users processed."