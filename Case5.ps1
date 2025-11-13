
#Case 5 nye AD-brugere fra CSV

#Indhold af CSV filen:

GivenName,Surname,SamAccountName,OU,Department,Email,Groups,TempPassword
Anna,Hansen,ahansen,"OU=TestUsers,DC=Mathias,DC=local",IT,anna.hansen@Mathias.local,"GGIT;GG-FileShare-IT",P@ssw0rd!
Bo,Nielsen,bnielsen,"OU=TestUsers,DC=Mathias,DC=local",Sales,bo.nielsen@Mathias.local,"GGSales",P@ssw0rd!
Carla,Østergaard,costergaard,"OU=TestUsers,DC=Mathias,DC=local",Ops,carla.ostergaard@Mathias.local,"GG-Operations",P@ssw0rd!
Emil,Olsen,eolsen,"OU=TestUsers,DC=Mathias,DC=local",,emil.olsen@Mathias.local,"GGIT;GG-FileShare-IT",P@ssw0rd!



# =============================
# Configuration
# =============================
$Server   = "10.101.190.204"
$Cred     = Get-Credential -username "Administrator"
$CSVPath  = "C:\Users\Emil\OneDrive - EFIF\Dokumenter\GitHub\Cases-wuhu---\NewUsers.csv"

# =============================
# Import CSV users
# =============================
$Users = @()
$Imported = Import-Csv -Path $CSVPath
if ($Imported) { $Users += $Imported }

# =============================
# Loop through each user
# =============================
foreach ($U in $Users) {
    Write-Host "== $($U.SamAccountName) ==" 

    Invoke-Command -ComputerName $Server -Credential $Cred -ScriptBlock {
        param($U)

        Import-Module ActiveDirectory
        $ErrorActionPreference = 'Stop'

        # OU for all users
        $OUPath = "OU=TestUsers,DC=Mathias,DC=local"

        # Check if user exists
        $exists = Get-ADUser -Filter "SamAccountName -eq '$($U.SamAccountName)'" -ErrorAction SilentlyContinue
        if ($exists) {
            Write-Output "EXISTS: $($exists.DistinguishedName)"
            return
        }

        # Create user
        New-ADUser `
            -Name "$($U.GivenName) $($U.Surname)" `
            -GivenName $U.GivenName `
            -Surname $U.Surname `
            -SamAccountName $U.SamAccountName `
            -UserPrincipalName "$($U.SamAccountName)@Mathias.local" `
            -EmailAddress $U.Email `
            -Path $OUPath `
            -AccountPassword (ConvertTo-SecureString $U.TempPassword -AsPlainText -Force) `
            -Enabled $true `
            -ChangePasswordAtLogon $true

        Write-Output "CREATED: $($U.SamAccountName)"

    } -ArgumentList $U

} # End foreach user




# Test for at lave en Group gennem WinRM. Det virker korrekt, men laver fejl fordi Powershell er dumt. Den siger den ikke kan finde gruppen, men den har oprettet den korrekt i AD.
# Configuration
# =============================
$Server = "10.101.190.204"
$Cred   = Get-Credential "Administrator"

# =============================
# Create the group
# =============================
Invoke-Command -ComputerName $Server -Credential $Cred -ScriptBlock {
    Import-Module ActiveDirectory

    $GroupName = "EmilsFuckingTestUsers"
    $OUPath    = "OU=TestUsers,DC=Mathias,DC=local"

    # Check if group already exists
    $grpExists = Get-ADGroup -Identity $GroupName -ErrorAction SilentlyContinue
    if ($grpExists) {
        Write-Output "Group '$GroupName' already exists."
    } else {
        # Create the group
        New-ADGroup -Name $GroupName `
                    -GroupScope Global `
                    -GroupCategory Security `
                    -Path $OUPath
        Write-Output "Group '$GroupName' created successfully."
    }
}


