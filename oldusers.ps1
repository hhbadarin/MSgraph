#Connect to MsGraph
Connect-MgGraph -Scopes "User.Read.All","Group.ReadWrite.All"

#Specify the path of the CSV file
$CSVFilePath = "$Home/Desktop/oldusers.csv"
$OldUsers = Import-Csv -Path $CSVFilePath

#Loop 
foreach ($User in $OldUsers) {Remove-MgUser -UserId $User.UserPrincipalName}

   