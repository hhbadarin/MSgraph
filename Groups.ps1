
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


#Export Classes with 0 members 
$Groups = Get-MgGroup -All | Where-Object {$_.MailNickName -like '*Section_*'} | Select-Object id, DisplayName, MailNickname
$Report = [System.Collections.Generic.List[Object]]::new()
ForEach ($Group in $Groups) {
    if ((Get-MgGroupMember -Groupid  $group.id).count -eq 0) {
        $ReportLine = [PSCustomObject]@{ 
            Group                = $Group.displayName
            Id                   = $Group.id
            Mail                 = $Group.mail 
            Created              = $Group.createdDateTime } 
            $Report.Add($ReportLine)
    }
}
$Report | Out-GridView
$Report | Export-CSV -Path "$Home/Desktop/ClassesWithZeroMembers.csv" -Encoding UTF8
