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
