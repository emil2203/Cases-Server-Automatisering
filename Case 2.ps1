Case 2

# Hent alle services fra serveren
Get-WmiObject -Class Win32_Service -ComputerName "10.101.155.147" -Credential (Get-Credential)

#Stop spooler service lol
Invoke-Command -ComputerName "10.101.155.147" -Credential (Get-Credential) -ScriptBlock {
    Stop-Service -Name "Spooler" -Force
}