
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
$Server     = "10.101.190.204"
$Cred       = Get-Credential -Username "Administrator"
$CSVPath    = "C:\Users\Emil\OneDrive - EFIF\Dokumenter\GitHub\Cases-wuhu---\NewUsers.csv"
$ReportPath = "C:\Users\Emil\OneDrive - EFIF\Dokumenter\GitHub\Cases-wuhu---\UserCreationReport.csv"
$TranscriptPath = "C:\Users\Emil\OneDrive - EFIF\Dokumenter\GitHub\Cases-wuhu---\UserCreationLog.txt"

# Start transcript (log all output)
Start-Transcript -Path $TranscriptPath -Force

# =============================
# Import CSV users
# =============================
$Users = Import-Csv -Path $CSVPath
$Report = @()

# =============================
# Loop through each user
# =============================
foreach ($U in $Users) {
    Write-Host "Processing user: $($U.SamAccountName)"
    $Status = ""

    try {
        $Status = Invoke-Command -ComputerName $Server -Credential $Cred -ScriptBlock {
            param($U)

            Import-Module ActiveDirectory
            $OUPath = $U.OU
            $ErrorActionPreference = 'Stop'

            # Check if user exists
            $exists = Get-ADUser -Filter "SamAccountName -eq '$($U.SamAccountName)'" -ErrorAction SilentlyContinue
            if ($exists) {
                # Optional: update user if exists
                Set-ADUser -Identity $U.SamAccountName `
                    -Department $U.Department `
                    -EmailAddress $U.Email `
                    -WhatIf -Confirm
                return "EXISTS (updated with -WhatIf)"
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
                -ChangePasswordAtLogon $true `
                -WhatIf -Confirm

            # Add user to groups
            if ($U.Groups) {
                $Groups = $U.Groups -split ';'
                foreach ($G in $Groups) {
                    Add-ADGroupMember -Identity $G -Members $U.SamAccountName -WhatIf -Confirm
                }
            }

            return "CREATED (-WhatIf enabled)"
        } -ArgumentList $U
    }
    catch {
        $Status = "ERROR: $($_.Exception.Message)"
    }

    # Add result to report
    $Report += [PSCustomObject]@{
        SamAccountName = $U.SamAccountName
        GivenName      = $U.GivenName
        Surname        = $U.Surname
        Status         = $Status
    }
}

# Export the report
$Report | Export-Csv -Path $ReportPath -NoTypeInformation
Write-Host "Report saved to $ReportPath"

# Stop transcript
Stop-Transcript






# Test for at lave en Group gennem WinRM. Det virker korrekt. Ikke en del af casen, men det er ekstra fordi jeg er sej
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


