
#Connect to Graph with the scopes
Connect-MgGraph -Scopes "User.Read.All","Group.ReadWrite.All"


#Create password profile
$PasswordProfile = @{
  Password                             = $User.Password
  ForceChangePasswordNextSignIn        = $false
  ForceChangePasswordNextSignInWithMfa = $false
}
  #Update-MgUser
  #Specify the path of the CSV file
  $CSVFilePath = "$Home\Documents\Github\Microsoft-Graph\Files\updateUsers.csv"
  #Import data from CSV file
  $Accounts = Import-Csv -Path $CSVFilePath
  #Loop through each row containing user details in the CSV file
  ForEach ($Account in $Accounts) {
    Update-MgUser -UserId $Account.UserPrincipalName -JobTitle $Account.JobTitle -PostalCode $Account.PostalCode -GivenName $Account.GivenName -Surname $Account.Surname -Department $Account.Department -PasswordProfile $PasswordProfile -PreferredLanguage "ar-SA" -UsageLocatio "PS"}
  
  //Update-MgUser PreferredLanguage
  #Specify the path of the CSV file
    $CSVFilePath = "$Home\Documents\Github\Microsoft-Graph\Files\newUsers.csv"
    #Import data from CSV file
    $Accounts = Import-Csv -Path $CSVFilePath
    #Loop through each row containing user details in the CSV file
    ForEach ($Account in $Accounts) {
      Update-MgUser -UserId $Account.UserPrincipalName -PreferredLanguage "ar-SA"}
  


#Link to attributes 
https://learn.microsoft.com/en-us/powershell/module/microsoft.graph.users/update-mguser?view=graph-powershell-1.0

//Set-MgUserPhotoContent


