#Du skal lave et script, der samler informationer om systemet (for eksempel CPU, RAM, netværkskort og
#operativsystem).
#Oplysningerne skal hentes via PowerShell og gemmes som en rapport i CSV-format. 


#Først lavet vi en C: Temp mappe

New-Item -Path "C:\Temp" -ItemType Directory -Force

#Laver rapporten: Forudsætter et Temp er lavet i forvejen

# Case 4: Systemrapport med pipeline
# Dette script henter CPU, RAM, netværkskort og OS info og gemmer som CSV

# CPU Information
$cpu = Get-CimInstance -ClassName Win32_Processor | 
       Select-Object Name, NumberOfCores, NumberOfLogicalProcessors, MaxClockSpeed

# RAM Information
$ram = Get-CimInstance -ClassName Win32_PhysicalMemory | 
       Select-Object Manufacturer, Capacity, Speed, MemoryType

# Netværkskort Information
$network = Get-CimInstance -ClassName Win32_NetworkAdapter |
           Where-Object {$_.NetEnabled -eq $true} |
           Select-Object Name, MACAddress, Speed

# Operating System Information
$os = Get-CimInstance -ClassName Win32_OperatingSystem |
      Select-Object Caption, Version, OSArchitecture, LastBootUpTime

# Sammensæt alt i én rapport
$report = [PSCustomObject]@{
    CPU        = ($cpu | ForEach-Object { $_.Name + " (" + $_.NumberOfCores + "C/" + $_.NumberOfLogicalProcessors + "T, " + $_.MaxClockSpeed + "MHz)" }) -join "; "
    RAM        = ($ram | ForEach-Object { $_.Manufacturer + " " + [math]::Round($_.Capacity/1GB,2) + "GB " + $_.Speed + "MHz" }) -join "; "
    Network    = ($network | ForEach-Object { $_.Name + " [" + $_.MACAddress + "] " + ($_.Speed/1MB) + "Mbps" }) -join "; "
    OS         = $os.Caption + " " + $os.Version + " (" + $os.OSArchitecture + ")"
    LastBoot   = $os.LastBootUpTime
}

# Gem rapporten i CSV
$report | Export-Csv -Path "C:\Temp\SystemRapport.csv" -NoTypeInformation

Write-Host "Systemrapport gemt som C:\Temp\SystemRapport.csv"



#Se den oprettede csv fil med denne kommand
Import-Csv -Path "C:\Temp\SystemRapport.csv"

#Se filen som ren fucking tekst 
Get-Content -Path "C:\Temp\SystemRapport.csv"

#Andre fucking måder at se filen
$report | Format-Table -AutoSize

