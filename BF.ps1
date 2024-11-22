# PowerShell script om wijzigingen aan achtergrondinstellingen ongedaan te maken

# Verwijder de beperking op wijzigen van de achtergrond
$regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\ActiveDesktop"
if (Test-Path $regPath) {
    Remove-ItemProperty -Path $regPath -Name "NoChangingWallpaper" -ErrorAction SilentlyContinue
    Write-Host "De beperking op wijzigen van de achtergrond is verwijderd."
} else {
    Write-Host "De beperking op wijzigen van de achtergrond bestaat niet."
}

# Herstel toegang tot de instellingen voor personalisatie
$regPath2 = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\System"
if (Test-Path $regPath2) {
    Remove-ItemProperty -Path $regPath2 -Name "NoDispBackgroundPage" -ErrorAction SilentlyContinue
    Write-Host "Toegang tot de instellingen voor personalisatie is hersteld."
} else {
    Write-Host "Er waren geen beperkingen op toegang tot de instellingen voor personalisatie."
}

# Optioneel: verwijder de gedownloade achtergrondafbeelding
$imagePath = "$env:USERPROFILE\Downloads\background.jpg"
if (Test-Path $imagePath) {
    Remove-Item $imagePath -Force
    Write-Host "De gedownloade achtergrondafbeelding is verwijderd."
} else {
    Write-Host "De achtergrondafbeelding werd niet gevonden."
}

Write-Host "Alle wijzigingen zijn ongedaan gemaakt."
