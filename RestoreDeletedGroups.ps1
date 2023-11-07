
Connect-Graph -Scopes "User.ReadWrite.All","Group.ReadWrite.All","AdministrativeUnit.ReadWrite.All"

#List Deleted Groups 
$DeletedGroups = (Get-MgDirectoryDeletedItem -DirectoryObjectId Microsoft.graph.group).AdditionalProperties['value']
If ($DeletedGroups.count -eq 0) {Write-Host "No groups were found"; break}
$Report = [System.Collections.Generic.List[Object]]::new(); $Now = Get-Date
ForEach ($Group in $DeletedGroups) {
    if ($Group.mail -like '*Section_*') {
        $ReportLine = [PSCustomObject]@{ 
            Group                = $Group.displayName
            Id                   = $Group.id
            Mail                 = $Group.mail 
            Created              = $Group.createdDateTime
            Deleted              = $Group.deletedDateTime} 
            $Report.Add($ReportLine) 
    }
}
$Report | Sort-Object {$_.PermanentDeleteOn -as [datetime]} | Out-GridView
$Report | Sort-Object {$_.PermanentDeleteOn -as [datetime]}  | Export-CSV -Path "$Home\Desktop\DeletedGroups.csv" -Encoding UTF8


#Restore Deleted Groups
$DeletedGroups = (Get-MgDirectoryDeletedItem -DirectoryObjectId Microsoft.graph.group).AdditionalProperties['value']
If ($DeletedGroups.count -eq 0) {Write-Host "No groups were found"; break}
ForEach ($Group in $DeletedGroups) {
    if ($Group.mail -like '*Section_*') {
        Restore-MgDirectoryDeletedItem -DirectoryObjectId $Group.id
    }
}

