#Specify the path of the CSV file
$CSVFilePath = "$Home/Desktop/newusers.csv"

#Create password profile
$PasswordProfile = @{
    Password                             = $User.Password
    ForceChangePasswordNextSignIn        = $false
    ForceChangePasswordNextSignInWithMfa = $false
}

#Import data from CSV file
$NewUsers = Import-Csv -Path $CSVFilePath

#Loop 
foreach ($User in $NewUsers) {
    $UserParams = @{
        DisplayName       = $User.DisplayName
        MailNickName      = $User.MailNickName
        UserPrincipalName = $User.UserPrincipalName
        Department        = $User.Department
        JobTitle          = $User.JobTitle
        GivenName         =$User.First
        Surname         =$User.Surname
        PasswordProfile   = $PasswordProfile
        AccountEnabled    = $true
			  UsageLocation     ="PS"
        PreferredLanguage  = "ar-SA"
        Country = "Palestinian Authority"
        City  = "Hebron"
        }

    try {
        $null = New-MgUser @UserParams -ErrorAction Stop
        Write-Host ("Successfully created the account for {0}" -f $User.DisplayName) -ForegroundColor Green
        $params = @{
            "@odata.id" = "https://graph.microsoft.com/v1.0/users/$($User.UserPrincipalName)"
        }
  
        Set-MgUserLicense -UserId $User.UserPrincipalName -AddLicenses @{SkuId = "94763226-9b3c-4e75-a931-5c89701abe66"} -RemoveLicenses @()
    }
    catch {
        Write-Host ("Failed to create the account for {0}. Error: {1}" -f $User.DisplayName, $_.Exception.Message) -ForegroundColor Red
    }
}