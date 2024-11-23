#Connect to Graph with the scopes
Connect-MgGraph -Scopes "User.Read.All","Group.ReadWrite.All"

#Update bulk users from a csv 
$Users = Import-Csv -Path "$Home\Desktop\updateUsers.csv"
$i = 0
ForEach ($User in $Users) {
    try {
        $i++
        Update-MgUser -UserId $User.UserPrincipalName -DisplayName $User.DisplayName 
        Write-Host ("User {0} has been updated to {1}" -f $User.UserPrincipalName, $User.DisplayName) -ForegroundColor Yellow
    }
    catch {
        Write-Host "An exception occurred: $($_.Exception.Message)"
        throw
    } 
}
