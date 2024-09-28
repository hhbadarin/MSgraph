
#Connect to MsGraph
Connect-MgGraph -Scopes "User.Read.All","Group.ReadWrite.All"
Connect-MgGraph -Scopes "Directory.AccessAsUser.All"

#List all licenses 
Get-MgSubscribedSku | Select-Object SkuPartNumber, SkuId


#Create new users
$i = 0
$NewUsers = Import-Csv -Path "$Home/Desktop/newusers.csv"
foreach ($User in $NewUsers) {
    #Create password profile
$PasswordProfile = @{
    Password                             = $User.Password
    ForceChangePasswordNextSignIn        = $false
    ForceChangePasswordNextSignInWithMfa = $false
}
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
        $i++
        $null = New-MgUser @UserParams -ErrorAction Stop
        Write-Host ("User {0} has been created ... ({1}/{2})" -f $User.UserPrincipalName, $i ,$Users.Count) -ForegroundColor Yellow
        Set-MgUserLicense -UserId $User.UserPrincipalName -AddLicenses @{SkuId = "94763226-9b3c-4e75-a931-5c89701abe66"} -RemoveLicenses @()
    }
    catch {
        Write-Host ("Failed to create the account for {0}. Error: {1}" -f $User.DisplayName, $_.Exception.Message) -ForegroundColor Red
    }
}

#Note: SkuId For students: 314c4481-f395-4525-be8b-2ec4bb1e9d91
