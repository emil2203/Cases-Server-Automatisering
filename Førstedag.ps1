# Brugeren skal skrive et ord
$word = Read-Host "name"

# Bogstaver den kigger efter
$letters = @("d","u","c","k")

# Se hvis nogle af de tal eksistere i ordet. Hvis IKKE så no output
if ($letters | Where-Object { $word -like "*$_*" }) {
    Write-Host "duck"
}