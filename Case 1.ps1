Case 1

# List all local drives
Get-PSDrive -PSProvider FileSystem


# Create folder for reports
New-Item -Path "C:\Reports" -ItemType Directory -Force

#Step 1: Find out where it was saved

#If you ran the previous script, the file was likely intended for:

C:\Reports\DiskReport.csv


#Check if the folder exists:

Test-Path "C:\Reports"


#If it returns False, the folder doesn’t exist.

#You must create it first:

New-Item -Path "C:\Reports" -ItemType Directory -Force

#Step 2: Generate the CSV
Get-PSDrive -PSProvider FileSystem | 
    Select-Object Name, Used, Free, Root | 
    Export-Csv -Path "C:\Reports\DiskReport.csv" -NoTypeInformation

#Step 3: Check the file exists
Test-Path "C:\Reports\DiskReport.csv"


#Should return True.

#Step 4: View the CSV
Get-Content "C:\Reports\DiskReport.csv"


#1️⃣ Opret mappen ScriptReports

#Åbn PowerShell som administrator og kør:

New-Item -Path "C:\ScriptReports" -ItemType Directory -Force


#Bekræft, at mappen blev oprettet:

Test-Path "C:\ScriptReports"


Hvis True → mappen eksisterer ✅

2️⃣ Opret PowerShell-scriptet DiskReport.ps1

Vi skriver nu scriptet direkte til filen:

$scriptPath = "C:\ScriptReports\DiskReport.ps1"

@'
# DiskReport.ps1 - daglig diskrapport
$reportFolder = "C:\ScriptReports"

# Hent filesystem drives og beregn brug/ledig i GB
$drives = Get-PSDrive -PSProvider FileSystem | Select-Object Name, Root, `
    @{Name='FreeGB';Expression={[math]::Round($_.Free/1GB,2)}}, `
    @{Name='UsedGB';Expression={[math]::Round(($_.Used/1GB),2)}}

# Vis tabel i konsol
$drives | Format-Table -AutoSize

# Gem CSV med dato
$csvPath = Join-Path $reportFolder ("DiskReport_" + (Get-Date).ToString("yyyy-MM-dd_HH-mm-ss") + ".csv")
$drives | Export-Csv -Path $csvPath -NoTypeInformation -Encoding UTF8

# Gem også seneste version som DiskReport_Latest.csv
$drives | Export-Csv -Path (Join-Path $reportFolder "DiskReport_Latest.csv") -NoTypeInformation -Encoding UTF8
'@ | Out-File -FilePath $scriptPath -Encoding UTF8 -Force


Bekræft filen blev lavet:

Get-Item "C:\ScriptReports\DiskReport.ps1"


#Kør scriptet direkte fra PowerShell:

powershell -ExecutionPolicy Bypass -File "C:\ScriptReports\DiskReport.ps1"


#Du skulle nu se en tabel med alle drives i konsollen

#CSV-filerne bliver oprettet i C:\ScriptReports:

DiskReport_<dato>.csv

DiskReport_Latest.csv

#Bekræft at CSV’en blev oprettet
Get-ChildItem "C:\ScriptReports" | Sort-Object LastWriteTime -Descending | Select-Object Name, LastWriteTime


#Den nyeste fil skal være DiskReport_Latest.csv eller en dato-version.


Import-Csv "C:\ScriptReports\DiskReport_Latest.csv" | Format-Table -AutoSize


