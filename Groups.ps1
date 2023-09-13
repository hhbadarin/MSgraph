
#Connect to MsGraph
Connect-MgGraph -Scopes "User.Read.All","Group.ReadWrite.All"

#Export synched groups
Get-MgGroup -All | Where-Object { $_.MailNickName -like '*Section_*' } | Select-Object id, DisplayName, MailNickname | Export-csv -NoTypeInformation $Home/Desktop/SynchedGroups.csv -Encoding UTF8

#Import and delete synched groups
$SynchedGroups = Import-Csv -Path $Home/Desktop/SynchedGroups.csv
ForEach ($group in $SynchedGroups) {
    Remove-MgGroup -GroupId $group.Id
    Write-Host ("Successfully deleted {0}" -f $group.DisplayName) -ForegroundColor Green
}