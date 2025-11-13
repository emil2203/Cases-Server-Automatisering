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
