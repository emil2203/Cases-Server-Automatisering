Get-ADUser

1.0.0.0 ActiveDirectory

whoami

# Hent alle brugere fra domænet Mathias.local
# Felter som aktive brugere viser hvornår de er skabt, sorter og gem som CSV

Get-ADUser -Server "Mathias.local" -Filter * -Properties whenCreated,Enabled |
Sort-Object Name |
Select-Object Name, SamAccountName, Enabled, whenCreated |
Export-Csv ".\AD_Users.csv" -NoTypeInformation -Encoding UTF8

Import-Csv ".\AD_Users.csv" | Format-Table -Auto

Name           SamAccountName Enabled whenCreated
----           -------------- ------- ------------
Administrator  Administrator  True    11-11-2025 02:43:28
Guest          Guest          False   11-11-2025 02:41:00
Test           Test           True    11-11-2025 02:41:00
Truser         Truser         True    11-11-2025 02:41:00

#Ekstra udfordring:
# Lav en lille rapport, der viser:
#Antal aktive brugere
# Antal brugere oprettet inden for de sidste 30 dage 


#Get-ADUser henter alle brugere fra domænet Mathias.local.

#AddDays(-30) definerer datogrænsen (30 dage tilbage).

#Scriptet tæller både samlet antal brugere og antal oprettet inden for 30 dage.

#Output bliver vist som en lille tabel i PowerShell.


$users = Get-ADUser -Server "Mathias.local" -Filter * -Properties whenCreated
$cutoff = (Get-Date).AddDays(-30)

$antalTotal = $users.Count
$antal30Dage = ($users | Where-Object { $_.whenCreated -ge $cutoff }).Count

# Lav rapport som et objekt
$report = [PSCustomObject]@{
    Domæne                = 'Mathias.local'
    'Antal brugere (total)' = $antalTotal
    'Oprettet (sidste 30 dage)' = $antal30Dage
}

# Vis rapport på skærmen
$report | Format-Table -Auto
