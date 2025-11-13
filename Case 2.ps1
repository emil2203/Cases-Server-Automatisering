Case 2

# Hent alle services fra serveren
Get-WmiObject -Class Win32_Service -ComputerName "10.101.155.147" -Credential (Get-Credential)

#Stop spooler service lol
Invoke-Command -ComputerName "10.101.155.147" -Credential (Get-Credential) -ScriptBlock {
    Stop-Service -Name "Spooler" -Force
}


#Get-WmiObject -Class Win32_Service queries WMI on the remote machine and returns service objects (name, state, start mode, etc.).

#-ComputerName "10.101.155.147" tells PowerShell which remote host to query.

#-Credential (Get-Credential) opens a prompt for username/password and uses those credentials for the WMI connection.

#Note: Get-WmiObject uses DCOM/WMI transport. In newer PowerShell versions you’ll often prefer Get-CimInstance (uses CIM/WinRM, more firewall-friendly).