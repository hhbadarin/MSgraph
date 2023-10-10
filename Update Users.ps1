#Connect to Graph with the scopes
Connect-MgGraph -Scopes "User.Read.All","Group.ReadWrite.All"

#Update
  #Specify the path of the CSV file
  $CSVFilePath = "$Home/Desktop/Updateusers.csv"
  #Import data from CSV file
  $Accounts = Import-Csv -Path $CSVFilePath
  #Loop through each row containing user details in the CSV file
  ForEach ($Account in $Accounts) {
    Update-MgUser -UserId $Account.UserPrincipalName -JobTitle $Account.JobTitle -GivenName $Account.GivenName -Surname $Account.Surname -Department $Account.Department
    }
